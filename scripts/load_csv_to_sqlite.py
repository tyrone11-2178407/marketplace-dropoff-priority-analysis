from pathlib import Path
import sqlite3
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = BASE_DIR / "data" / "raw"
DB_PATH = BASE_DIR / "data" / "olist.db"

TABLE_FILES = {
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "payments",
    "olist_order_reviews_dataset.csv": "reviews",
    "olist_customers_dataset.csv": "customers",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "olist_geolocation_dataset.csv": "geolocation",
}

def main():
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)

    conn = sqlite3.connect(DB_PATH)

    try:
        for csv_file, table_name in TABLE_FILES.items():
            csv_path = RAW_DIR / csv_file

            if not csv_path.exists():
                print(f"Missing file: {csv_file}")
                continue

            print(f"Loading {csv_file} -> {table_name}")
            df = pd.read_csv(csv_path)
            df.to_sql(table_name, conn, if_exists="replace", index=False)

        print("\nDone.")
        print(f"Database created at: {DB_PATH}")

    finally:
        conn.close()

if __name__ == "__main__":
    main()