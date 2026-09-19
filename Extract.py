"""
Exporta las tablas finales de reporting (esquema marts) a archivos, para
usarlas en una herramienta de BI (Power BI, Tableau Public, Looker Studio, etc.).

Uso (desde la raíz del repo, con dbt ya ejecutado):
    python exports/export_reports.py                 # CSV (por defecto)
    python exports/export_reports.py --format parquet
    python exports/export_reports.py --format both

Salida: exports/output/<tabla>.csv y/o .parquet
La conexión es de solo lectura: el script no modifica el warehouse.
"""
import argparse
from pathlib import Path

import duckdb

HERE = Path(__file__).resolve().parent
ROOT = next(p for p in [HERE, *HERE.parents] if (p / "warehouse.duckdb").exists())
DB = ROOT / "warehouse.duckdb"
OUTPUT_DIR = ROOT / "exports" / "output"

# Tablas a exportar (esquema.tabla). Agregá "marts.rpt_data_quality" si
# querés también el panel de calidad de datos en el dashboard.
TABLES = [
    "marts.rpt_product_performance",
    "marts.rpt_sales_by_hour",
]


def export_table(con, table, fmt):
    name = table.split(".")[1]
    path = (OUTPUT_DIR / f"{name}.{fmt}").as_posix()
    options = "FORMAT csv, HEADER" if fmt == "csv" else "FORMAT parquet"
    con.execute(f"COPY (SELECT * FROM {table}) TO '{path}' ({options})")
    rows = con.execute(f"SELECT count(*) FROM {table}").fetchone()[0]
    print(f"  {table:<35} -> {Path(path).name:<32} ({rows} filas)")


def main():
    parser = argparse.ArgumentParser(description="Exporta las tablas de reporting.")
    parser.add_argument(
        "--format", choices=["csv", "parquet", "both"], default="csv",
        help="Formato de salida (default: csv)",
    )
    args = parser.parse_args()
    formats = ["csv", "parquet"] if args.format == "both" else [args.format]

    if not DB.exists():
        raise SystemExit(f"No se encontró el warehouse en {DB}. Ejecutá la ingesta y dbt primero.")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    con = duckdb.connect(str(DB), read_only=True)
    try:
        print(f"Exportando a {OUTPUT_DIR}")
        for fmt in formats:
            for table in TABLES:
                export_table(con, table, fmt)
    finally:
        con.close()

    print("Listo.")


if __name__ == "__main__":
    main()