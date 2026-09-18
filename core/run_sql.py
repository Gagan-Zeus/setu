#!/usr/bin/env python3
"""Run a SQL file against a Supabase project without psql.

    SUPABASE_ACCESS_TOKEN=sbp_... python3 core/run_sql.py <project-ref> <file.sql>

There is no psql on this machine and no Postgres driver installed, so the
Management API's query endpoint is the way in. It takes the whole file as one
statement batch, which is what the dashboard's SQL editor does too - so a file
that works here works there, and vice versa.

The token is account-wide, not project-scoped. Read it from the environment,
never take it as an argument: arguments end up in shell history.
"""

import json
import os
import sys
import urllib.error
import urllib.request

API = "https://api.supabase.com/v1/projects/{ref}/database/query"


def run(ref: str, sql: str) -> object:
    request = urllib.request.Request(
        API.format(ref=ref),
        data=json.dumps({"query": sql}).encode(),
        headers={
            "Authorization": f"Bearer {os.environ['SUPABASE_ACCESS_TOKEN']}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    with urllib.request.urlopen(request) as response:
        return json.loads(response.read() or "[]")


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: run_sql.py <project-ref> <file.sql>")
    if "SUPABASE_ACCESS_TOKEN" not in os.environ:
        raise SystemExit("export SUPABASE_ACCESS_TOKEN=sbp_...")

    ref, path = sys.argv[1], sys.argv[2]
    sql = open(path).read()
    print(f"{path}: {len(sql) // 1024}KB -> {ref}")

    try:
        result = run(ref, sql)
    except urllib.error.HTTPError as error:
        # The API puts the Postgres error in the body, not the status line.
        # Printing only the status turns a precise "column x does not exist"
        # into an opaque 400.
        print(f"\nFAILED {error.code}", file=sys.stderr)
        print(error.read().decode(), file=sys.stderr)
        raise SystemExit(1)

    if isinstance(result, list) and result:
        print(json.dumps(result[:20], indent=2)[:4000])
    print("OK")


if __name__ == "__main__":
    main()
