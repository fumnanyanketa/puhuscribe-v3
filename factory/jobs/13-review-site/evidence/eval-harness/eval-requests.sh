B=http://127.0.0.1:8788
T=clean/eval-harness/tokens.json
tok() { node -e "process.stdout.write(require('./$T')['$1'])"; }
V=$(tok valid)
row() { printf '%-62s %s\n' "$1" "$2"; }
echo "# Harness: the real review-site/handler.ts in wrangler dev (workerd, real assets binding from dist-review/),"
echo "# with a locally made key set in place of the Access certs fetch. Settings: a made up team and AUD."
echo
echo "## Tokens on GET /meeting-people-new-colleague/round-1"
row "no header" "$(curl -s -o /dev/null -w '%{http_code}' $B/meeting-people-new-colleague/round-1)"
for t in valid wrong_signature wrong_aud wrong_iss expired no_exp not_yet_valid alg_es256_other_key alg_none alg_hs256 tampered_payload malformed empty_string; do
  row "token: $t" "$(curl -s -o /dev/null -w '%{http_code}' -H "Cf-Access-Jwt-Assertion: $(tok $t)" $B/meeting-people-new-colleague/round-1)"
done
row "valid token in a cookie only (CF_Authorization), no header" "$(curl -s -o /dev/null -w '%{http_code}' -H "Cookie: CF_Authorization=$V" $B/meeting-people-new-colleague/round-1)"
row "valid token as Authorization: Bearer, no header" "$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $V" $B/meeting-people-new-colleague/round-1)"
row "header name in lower case" "$(curl -s -o /dev/null -w '%{http_code}' -H "cf-access-jwt-assertion: $V" $B/meeting-people-new-colleague/round-1)"
echo
echo "## Paths with a valid token (status, Location if any, bytes)"
for p in / /index.html /robots.txt /meeting-people-new-colleague/round-1 /meeting-people-new-colleague/round-1.html /meeting-people-new-colleague/round-1/ \
  /meeting-people-new-colleague/round-2 /meeting-people-new-colleague/round-01 /meeting-people-new-colleague/round-0 /Meeting-people-new-colleague/round-1 \
  /unlisted-dialogue/round-1 /meeting-people-new-colleague/ /meeting-people-new-colleague /meeting-people-new-colleague/round-1.json \
  /meeting-people-new-colleague/draft.json /meeting-people-new-colleague/audio/1-puhe.mp3 /content/drafts/meeting-people-new-colleague/draft.json \
  /review-site/dialogues.json /.wrangler /.wrangler/ /.git/config /dist-review/index.html //meeting-people-new-colleague/round-1 ///robots.txt \
  /meeting-people-new-colleague//round-1 /../../package.json /meeting-people-new-colleague/../robots.txt /%2e%2e/%2e%2e/package.json \
  /meeting-people-new-colleague%2Fround-1 /meeting-people-new-colleague%2fround-1 /meeting-people-new-colleague/round-1%2Ehtml /meeting-people-new-colleague/round-1%00 \
  '/meeting-people-new-colleague/round-1?x=1' '/meeting-people-new-colleague/round-1;x' /index.html/ /robots.txt/ /favicon.ico /cdn-cgi/access/certs /cdn-cgi/local/explorer/api; do
  r=$(curl -s --path-as-is -o /tmp/eval-body -w '%{http_code} %{redirect_url} %{size_download}' -H "Cf-Access-Jwt-Assertion: $V" "$B$p")
  row "GET $p" "$r"
done
echo
echo "## Same odd paths without a token (all must be 403)"
for p in / /robots.txt //meeting-people-new-colleague/round-1 /../../package.json /.wrangler /meeting-people-new-colleague%2Fround-1 /cdn-cgi/local/explorer/api; do
  row "GET $p" "$(curl -s --path-as-is -o /dev/null -w '%{http_code}' "$B$p")"
done
echo
echo "## Methods with a valid token"
for m in POST PUT PATCH DELETE OPTIONS TRACE CONNECT PROPFIND; do
  row "$m /meeting-people-new-colleague/round-1" "$(curl -s -o /dev/null -w '%{http_code}' -X $m -H "Cf-Access-Jwt-Assertion: $V" $B/meeting-people-new-colleague/round-1)"
done
row "POST / with a 2 MB body" "$(head -c 2000000 /dev/zero | curl -s -o /dev/null -w '%{http_code}' -X POST --data-binary @- -H "Cf-Access-Jwt-Assertion: $V" $B/)"
row "GET / straight after that POST (same server)" "$(curl -s -o /dev/null -w '%{http_code}' -H "Cf-Access-Jwt-Assertion: $V" $B/)"
row "HEAD /meeting-people-new-colleague/round-1 (bytes)" "$(curl -s -I -o /dev/null -w '%{http_code} %{size_download}' -H "Cf-Access-Jwt-Assertion: $V" $B/meeting-people-new-colleague/round-1)"
row "GET with If-None-Match (must still be full 200)" "$(curl -s -o /dev/null -w '%{http_code} %{size_download}' -H 'If-None-Match: *' -H "Cf-Access-Jwt-Assertion: $V" $B/meeting-people-new-colleague/round-1)"
row "GET with Range: bytes=0-9" "$(curl -s -o /dev/null -w '%{http_code} %{size_download}' -H 'Range: bytes=0-9' -H "Cf-Access-Jwt-Assertion: $V" $B/meeting-people-new-colleague/round-1)"
echo
echo "## Served page is byte for byte the committed file"
curl -s -H "Cf-Access-Jwt-Assertion: $V" $B/meeting-people-new-colleague/round-1 | sha256sum
(cd clean && git show HEAD:content/drafts/meeting-people-new-colleague/review/round-1.html) | sha256sum
echo
for p in / /robots.txt /meeting-people-new-colleague/round-1 /meeting-people-new-colleague/round-1.html /nope; do
  echo "## Headers: GET $p (valid token)"; curl -s -o /dev/null -D - -H "Cf-Access-Jwt-Assertion: $V" "$B$p" | tr -d '\r'; done
echo "## Headers: POST / (405)"; curl -s -o /dev/null -D - -X POST -H "Cf-Access-Jwt-Assertion: $V" "$B/" | tr -d '\r'
echo "## Headers: GET / with expired token (403)"; curl -s -o /dev/null -D - -H "Cf-Access-Jwt-Assertion: $(tok expired)" "$B/" | tr -d '\r'
echo "## Body of 404"; curl -s -H "Cf-Access-Jwt-Assertion: $V" "$B/nope"
