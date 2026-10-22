// Local, read only dashboard for the PuhuScribe factory.
// Serves index.html and /api/state, which bundles board.json, features.json
// and every job's markdown files. Binds to 127.0.0.1 only. No dependencies.
import { createServer } from "node:http";
import { readFile, readdir } from "node:fs/promises";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const here = dirname(fileURLToPath(import.meta.url));
const factory = join(here, "..");
const port = Number(process.env.PORT) || 4321;

async function readJson(path, fallback) {
  try {
    return JSON.parse(await readFile(path, "utf8"));
  } catch {
    return fallback;
  }
}

async function jobFiles(jobId) {
  const dir = join(factory, "jobs", jobId);
  const files = {};
  let evidence = [];
  try {
    for (const name of await readdir(dir)) {
      if (name.endsWith(".md")) files[name] = await readFile(join(dir, name), "utf8");
    }
    evidence = await readdir(join(dir, "evidence"));
  } catch {
    // Job folder or evidence folder not created yet.
  }
  return { files, evidence };
}

const repo = join(factory, "..");
const run = promisify(execFile);
async function cmd(file, args, cwd = repo) {
  try {
    return (await run(file, args, { cwd, timeout: 15000, windowsHide: true })).stdout;
  } catch {
    return "";
  }
}

// Live work inside a stage: the job branch's commits, files the builder is
// editing right now, and the pull request's GitHub checks.
const ghCache = new Map();
async function live(job) {
  if (job.stage === "merged") return null;
  const branch = `factory/${job.id}`;
  const worktree = join(repo, ".worktrees", job.id);
  const log = await cmd("git", ["log", `main..${branch}`, "--format=%h%x09%cI%x09%s"]);
  const commits = log.trim().split("\n").filter(Boolean).map((l) => {
    const [hash, time, ...s] = l.split("\t");
    return { hash, time, subject: s.join("\t") };
  });
  const editing = (await cmd("git", ["status", "--porcelain"], worktree))
    .split("\n").filter(Boolean).map((l) => l.slice(3)).filter((f) => !f.startsWith(".env"));

  let gh = ghCache.get(job.id);
  if (!gh || Date.now() - gh.at > 20000) {
    const pr = JSON.parse((await cmd("gh", ["pr", "list", "--head", branch, "--state", "all", "--json", "number,url,state,isDraft"])) || "[]")[0] || null;
    const checks = pr ? JSON.parse((await cmd("gh", ["pr", "checks", String(pr.number), "--json", "name,bucket,completedAt"])) || "[]") : [];
    gh = { at: Date.now(), pr, checks };
    ghCache.set(job.id, gh);
  }
  return { commits, editing, pr: gh.pr, checks: gh.checks };
}

async function state() {
  const board = await readJson(join(factory, "board.json"), { jobs: [] });
  const features = await readJson(join(factory, "features.json"), { features: [] });
  const jobs = await Promise.all(
    (board.jobs || []).map(async (job) => ({ ...job, ...(await jobFiles(job.id)), live: await live(job) }))
  );
  return { jobs, features: features.features || [], mvp: features.mvp || "" };
}

const types = { ".png": "image/png", ".jpg": "image/jpeg", ".webm": "video/webm", ".mp4": "video/mp4" };

createServer(async (req, res) => {
  const url = new URL(req.url, "http://localhost");
  try {
    if (url.pathname === "/api/state") {
      res.writeHead(200, { "content-type": "application/json", "cache-control": "no-store" });
      res.end(JSON.stringify(await state()));
      return;
    }
    // /evidence/<job-id>/<file>: only names that exist in that job's evidence folder.
    const m = url.pathname.match(/^\/evidence\/([\w-]+)\/([^/]+)$/);
    if (m) {
      const { evidence } = await jobFiles(m[1]);
      const name = decodeURIComponent(m[2]);
      if (!evidence.includes(name)) throw new Error("not found");
      const ext = name.slice(name.lastIndexOf("."));
      res.writeHead(200, { "content-type": types[ext] || "application/octet-stream" });
      res.end(await readFile(join(factory, "jobs", m[1], "evidence", name)));
      return;
    }
    if (url.pathname === "/") {
      res.writeHead(200, { "content-type": "text/html; charset=utf-8" });
      res.end(await readFile(join(here, "index.html")));
      return;
    }
    res.writeHead(404).end("Not found");
  } catch {
    res.writeHead(404).end("Not found");
  }
}).listen(port, "127.0.0.1", () => {
  console.log(`Factory dashboard: http://localhost:${port}`);
});
