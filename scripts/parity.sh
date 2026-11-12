#!/usr/bin/env bash
# 差分测试：同一个请求分别打原版(NestJS)和 Java 版，比对响应体。
#
# 用法：
#   bash scripts/parity.sh POST /api/auth/login '{"email":"a@b.c","password":"123456"}'
#   bash scripts/parity.sh GET  /api/analytics/overview ''
#
# 环境变量：
#   ORACLE=http://127.0.0.1:3100   Java=http://127.0.0.1:3000
#   TOKEN=...                      需要鉴权的接口把 token 放这里
set -uo pipefail

METHOD="${1:?method required}"
PATH_="${2:?path required}"
BODY="${3:-}"

ORACLE="${ORACLE:-http://127.0.0.1:3100}"
JAVA="${JAVA:-http://127.0.0.1:3000}"
TOKEN="${TOKEN:-}"

call() {
  local base="$1" out="$2"
  local args=(-sS -X "$METHOD" "$base$PATH_" -H 'Content-Type: application/json' -o "$out" -w '%{http_code}')
  [ -n "$TOKEN" ] && args+=(-H "Authorization: Bearer $TOKEN")
  [ -n "$BODY" ] && args+=(-d "$BODY")
  curl "${args[@]}"
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

o_code="$(call "$ORACLE" "$TMP/oracle.json")"
j_code="$(call "$JAVA"   "$TMP/java.json")"

echo "HTTP  oracle=$o_code  java=$j_code"
if [ "$o_code" != "$j_code" ]; then
  echo "FAIL: 状态码不一致"
fi

# 用 python 做 JSON 归一化比较（key 顺序、数字/字符串差异都能看出来）
python - "$TMP/oracle.json" "$TMP/java.json" <<'PY'
import json, sys, difflib

def load(p):
    with open(p, encoding='utf-8') as f:
        raw = f.read()
    try:
        return json.dumps(json.loads(raw), ensure_ascii=False, sort_keys=True, indent=2)
    except json.JSONDecodeError:
        return raw

a, b = load(sys.argv[1]), load(sys.argv[2])
if a == b:
    print("PASS: 响应体一致")
    sys.exit(0)

print("FAIL: 响应体不一致\n")
for line in difflib.unified_diff(a.splitlines(), b.splitlines(),
                                 fromfile='oracle(NestJS)', tofile='java', lineterm=''):
    print(line)
sys.exit(1)
PY
