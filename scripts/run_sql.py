from pathlib import Path
import sqlite3
import sys


BASE_DIR = Path(__file__).resolve().parent.parent
DB_PATH = BASE_DIR / "data" / "olist.db"


def split_sql_statements(sql_text: str) -> list[str]:
    statements = []
    current = []

    for line in sql_text.splitlines():
        stripped = line.strip()

        if not stripped or stripped.startswith("--"):
            continue

        current.append(line)

        if stripped.endswith(";"):
            statements.append("\n".join(current).strip())
            current = []

    if current:
        statements.append("\n".join(current).strip())

    return statements


def print_results(cursor: sqlite3.Cursor) -> None:
    rows = cursor.fetchall()

    if cursor.description is None:
        print("Statement executed.\n")
        return

    headers = [column[0] for column in cursor.description]
    print(" | ".join(headers))
    print("-" * (len(" | ".join(headers))))

    for row in rows:
        print(" | ".join("" if value is None else str(value) for value in row))

    print(f"\nRows returned: {len(rows)}\n")


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python scripts/run_sql.py <sql_file>")
        return 1

    sql_path = (BASE_DIR / sys.argv[1]).resolve()

    if not sql_path.exists():
        print(f"SQL file not found: {sql_path}")
        return 1

    if not DB_PATH.exists():
        print(f"Database not found: {DB_PATH}")
        print("Run python scripts/load_csv_to_sqlite.py first.")
        return 1

    sql_text = sql_path.read_text(encoding="utf-8")
    statements = split_sql_statements(sql_text)

    if not statements:
        print(f"No SQL statements found in: {sql_path}")
        return 1

    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()

        for index, statement in enumerate(statements, start=1):
            print(f"--- Statement {index} ---")
            print(statement)
            print()
            cursor.execute(statement)
            print_results(cursor)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
