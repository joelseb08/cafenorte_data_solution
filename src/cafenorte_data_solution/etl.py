import polars as pl
from json import loads
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent
class Extract_Transform:
    def __init__(self, data_path: str = PROJECT_ROOT / "data"):
        self.root = PROJECT_ROOT
        self.data_path = Path(data_path)
    
    def inventory(self) -> dict[str, pl.DataFrame]:
        path = self.data_path / "inventory.json"
        data = loads(path.read_text(encoding="utf-8"))
        data = {
            "sku_mappings": self.transform_sku_mappings(
                pl.from_dicts(data["catalogo"]["productos"], schema=["sku_erp","nombre"])
            ),
            "tiendas_info": pl.from_dicts(data["tiendas_info"]),
            **self.transform_catalogo_productos(
                pl.from_dicts(
                    data["catalogo"]["productos"],
                    schema_overrides={
                        "cost_history": pl.List(
                            pl.Struct({
                                "fecha_vigencia": pl.Utf8,
                                "costo_mxn": pl.Utf8,
                                "proveedor": pl.Utf8,
                            })
                        )
                    }
                )
            ),
            "snapshots": self.transform_snapshots(
                pl.from_dicts(
                    data["snapshots"],
                    schema = {"fecha": pl.Utf8, "tienda_id": pl.Utf8, "sku_erp": pl.Utf8, "cantidad_en_stock": pl.Utf8}
                )
            )
        }
        return data
    
    def exchange_rates(self) -> pl.DataFrame:
        path = self.data_path / "exchange_rates.csv"
        data = (
            pl.scan_csv(path, schema={
                "fecha": pl.Date,
                "currency": pl.Utf8,
                "rate_to_mxn": pl.Decimal(10, 4)
            })
            .with_columns(
                pl.col("currency").str.replace_many(["USD", "EUR"], ["2", "3"]).cast(pl.Int8)
            )
            .rename({"currency": "currency_id"})
            .collect()
        )
        return data
    
    def ecommerce_sales(self) -> pl.DataFrame:
        path = self.data_path / "ecommerce_orders.parquet"
        data = (
            pl.scan_parquet(path)
            .with_columns(
                pl.col("product_handle").str.extract(r"\d+", 0).cast(pl.Int32).alias("product_handle"),
                pl.col("cantidad").cast(pl.Int16).alias("cantidad"),
                pl.col("currency").str.replace_many(["MXN", "USD", "EUR"], ["1", "2", "3"]).cast(pl.Int8).alias("currency"),
                pl.col("amount").cast(pl.Decimal(10, 2)).alias("amount"),
                pl.col("fecha").str.strptime(pl.Datetime, "%Y-%m-%d %H:%M:%S").alias("fecha")
            )
            .collect()
        )
        return data
    
    def pos_sales(self) -> pl.DataFrame:
        path = self.data_path / "sales.csv"
        data = (
            pl.scan_csv(path)
            .with_columns(
                pl.col("fecha_hora").str.strptime(pl.Datetime, "%Y-%m-%d %H:%M:%S").alias("fecha_hora"),
                pl.col("tienda_id").str.extract(r"\d+", 0).cast(pl.Int32).alias("tienda_id"),
                pl.col("sku").str.extract(r"\d+", 0).cast(pl.Int32).alias("sku"),
                pl.col("moneda").str.replace_many(["MXN", "USD", "EUR"], ["1", "2", "3"]).cast(pl.Int8).alias("moneda"),
                pl.col("monto").cast(pl.Decimal(10, 2)).alias("monto"),
                pl.col("cantidad").cast(pl.Int16).alias("cantidad")
            )
            .collect()
        )
        return data
    
    def transform_sku_mappings(self, df: pl.DataFrame) -> pl.DataFrame:
        data = (
            df.with_columns(
                pl.col("sku_erp").str.extract(r"\d+", 0).str.to_integer().alias("sku_seq")
            )
            .with_columns(
                pl.concat_str(
                    pl.lit("CN-"),
                    pl.col("sku_seq").cast(pl.Utf8).str.zfill(5)
                ).alias("sku_pos"),
                pl.concat_str(
                    pl.col("nombre").str.to_lowercase().str.replace_all(" ","-"), pl.lit("-"),
                    pl.col("sku_seq").cast(pl.Utf8).str.zfill(3)
                ).alias("handle")
            )
            .select(["sku_pos", "sku_erp", "handle"])
        )
        return data
    
    def transform_catalogo_productos(self, df: pl.DataFrame) -> dict[str, pl.DataFrame]:
        data = df.with_columns(
            pl.col("sku_erp").str.extract(r"\d+", 0).cast(pl.Int32).alias("sku_erp")
        )
        
        catalogo = {
            "catalogo_productos": data.select(["sku_erp", "nombre", "categoria"]),
            "catalogo_proveedores": (
                data.explode("cost_history", empty_as_null=True)
                .with_columns(
                    pl.col("cost_history")
                    .struct.with_fields(
                        pl.field("fecha_vigencia").str.to_date(format="%Y-%m-%d").dt.date(),
                        pl.field("costo_mxn").str.to_decimal(scale=2)
                    )
                )
                .unnest("cost_history")
                .select(["sku_erp", "fecha_vigencia", "costo_mxn", "proveedor"])
            )
        }
        
        return catalogo
    
    def transform_snapshots(self, df: pl.DataFrame) -> pl.DataFrame:
        data = (
            df.with_columns(
                pl.col("fecha").str.to_date(),
                pl.col("cantidad_en_stock").cast(pl.Int32, strict=False).fill_null(0),
                pl.col("tienda_id").str.extract(r"\d+", 0).cast(pl.Int32).fill_null(0),
                pl.col("sku_erp").str.extract(r"\d+", 0).cast(pl.Int32).fill_null(0)
            )
        )
        return data
    