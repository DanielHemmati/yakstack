from pathlib import Path

from diagrams import Diagram, Edge
from diagrams.aws.analytics import Athena, Glue, GlueCrawlers, GlueDataCatalog
from diagrams.aws.storage import S3
from diagrams.generic.storage import Storage


lab_dir = Path(__file__).resolve().parents[1]
output_dir = lab_dir / "assets"
output_dir.mkdir(exist_ok=True)

with Diagram(
    "AWS Glue and Athena Learning Lab",
    filename=str(output_dir / "architecture"),
    outformat="png",
    direction="LR",
    show=False,
    graph_attr={"nodesep": "0.6", "ranksep": "0.8", "splines": "spline"},
    node_attr={"height": "0.5", "imagepos": "tc"},
):
    source = Storage("Local CSV\nusers.csv")
    raw = S3("S3 raw data\nraw/users/")
    raw_crawler = GlueCrawlers("Raw crawler")
    users_table = GlueDataCatalog("Catalog table\nusers")
    etl_job = Glue("Users transform\nETL job")
    processed = S3("S3 partitioned Parquet\nprocessed/users/\ncountry=VALUE/")
    processed_crawler = GlueCrawlers("Processed crawler")
    processed_table = GlueDataCatalog("Catalog table\nprocessed_users")
    athena = Athena("Athena workgroup")
    results = S3("S3 query results\nathena-results/")

    source >> Edge(label="upload") >> raw
    raw >> Edge(label="infer schema") >> raw_crawler
    raw_crawler >> users_table
    users_table >> Edge(label="read") >> etl_job
    etl_job >> Edge(label="write Parquet") >> processed
    processed >> Edge(label="catalog partitions") >> processed_crawler
    processed_crawler >> processed_table
    [users_table, processed_table] >> Edge(label="query") >> athena
    athena >> Edge(label="store results") >> results
