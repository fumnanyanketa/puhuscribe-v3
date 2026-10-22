== README links to the spec's Decision section
7:The full decision, with the runner up for each choice and why it lost, is in [factory/jobs/1-stack/spec.md](factory/jobs/1-stack/spec.md#decision).
== Target exists in this branch and has a Decision heading
-rw-r--r-- 1 fumna 197609 28750 Oct 19 20:52 factory/jobs/1-stack/spec.md
32:## Decision
52:### The stack
72:### Provisional providers (decision 8 of the factory plan)
87:### Secrets and accounts
== Branch spec vs main spec
== Stack table rows in spec (Layer | Pick | Runner up | Why lost): count of rows with 4 non-empty cells
4/4 cells:  Frontend 
4/4 cells:  Hosting for the app and its API 
4/4 cells:  Scaffold 
4/4 cells:  Preview links 
4/4 cells:  Separating test from live 
4/4 cells:  Database, sign in, access rules 
4/4 cells:  Database environments 
4/4 cells:  Package manager and runtime 
4/4 cells:  Unit tests 
4/4 cells:  Browser tests 
4/4 cells:  Lint and format (TypeScript) 
4/4 cells:  Python 
4/4 cells:  Secret scan 
4/4 cells:  Dependency check 
4/4 cells:  Finnish word checker hosting 
== Running costs section
## Running costs

| Service                                                  | Plan                               | Cost today |
| -------------------------------------------------------- | ---------------------------------- | ---------- |
| GitHub (private repository, Actions checks)              | Free (2,000 check minutes a month) | €0         |
| Cloudflare Workers (app, API, preview links)             | Workers Free                       | €0         |
| Cloudflare Zero Trust (Access sign in for preview links) | Free (up to 50 users)              | €0         |
| Supabase (test project `puhuscribe-test`)                | Free                               | €0         |
