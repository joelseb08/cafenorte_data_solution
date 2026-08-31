import cafenorte_data_solution.etl as etl
from adbc_driver_manager.dbapi import connect
from pathlib import Path
import polars as pl
from dotenv import load_dotenv
from os import getenv
import sys

load_dotenv()

def execute_init_queries() -> None:    
    path = Path("./queries").glob("[1-9]*?.sql")
    user = getenv("USER_DB_CAFENORTE")
    passwd = getenv("PASSWD_DB_CAFENORTE")
    db = getenv("NAME_DB_CAFENORTE")
    
    with connect("postgresql", f"postgresql://{user}:{passwd}@localhost:5432/{db}", autocommit=True) as conn:
        cursor = conn.cursor()
        for sql_file in sorted(path):
            query = sql_file.read_text(encoding="utf-8")
            cursor.executescript(query)


def all_data(path: str) -> dict[str, pl.DataFrame]:
    execute_init_queries()
    manager = etl.Extract_Transform(path)
    inventory = manager.inventory()
    data_dict = {
        "sku_mappings": {
            "data": inventory["sku_mappings"],
            "queries_pre_load": [
                "SET search_path TO inventory;",
                "TRUNCATE TABLE sku_mappings RESTART IDENTITY CASCADE;"
            ]
        },
        "tiendas_info": {
            "data": inventory["tiendas_info"],
            "queries_pre_load": [
                "SET search_path TO inventory;",
                "TRUNCATE TABLE tiendas_info RESTART IDENTITY CASCADE;"
            ]
        },
        "catalogo_proveedores": {
            "data": inventory["catalogo_proveedores"],
            "queries_pre_load": [
                "SET search_path TO inventory;",
                "TRUNCATE TABLE catalogo_proveedores RESTART IDENTITY;"
            ]
        },
        "catalogo_productos": {
            "data": inventory["catalogo_productos"],
            "queries_pre_load": [
                "SET search_path TO inventory;",
                "TRUNCATE TABLE catalogo_productos RESTART IDENTITY;"
            ]
        },
        "snapshots": {
            "data": inventory["snapshots"],
            "queries_pre_load": [
                "SET search_path TO inventory;",
                "TRUNCATE TABLE snapshots RESTART IDENTITY;"
            ]
        },
        "rates": {
            "data": manager.exchange_rates(),
            "queries_pre_load": [
                "SET search_path TO exchange_rates;",
                "TRUNCATE TABLE rates RESTART IDENTITY;"
            ]
        },
        "ecommerce_sales": {
            "data": manager.ecommerce_sales(),
            "queries_pre_load": [
                "SET search_path TO sales;",
                "TRUNCATE TABLE ecommerce_sales RESTART IDENTITY;"
            ]
        },
        "points_of_sale": {
            "data": manager.pos_sales(),
            "queries_pre_load": [
                "SET search_path TO sales;",
                "TRUNCATE TABLE points_of_sale RESTART IDENTITY;"
            ]
        }
    }
    return data_dict

def main():
    if len(sys.argv) < 2:
        print("Error: Falta especificar la ruta.")
        sys.exit(1)
    path = Path(sys.argv[1])
    print(f"Procesando archivos en la ruta: {path}")
    
    data = all_data(path)
    with connect("postgresql", "postgresql://usr_cafenorte:CafeNorte2026-08@localhost:5432/cafenorte", autocommit=True) as conn:
        cursor = conn.cursor()
        for table, value in data.items():
            data: pl.DataFrame = value["data"]
            queries = value["queries_pre_load"]
            
            for query in queries:
                cursor.execute(query)
                
            data.write_database(
                table,
                conn,
                engine="adbc",
                if_table_exists="append"
            )
    
    print("✅ Datos cargados correctamente en la base de datos.")
    
if __name__ == "__main__":
    main()