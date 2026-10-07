import sys

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql.functions import col, upper


args = getResolvedOptions(
    sys.argv,
    ["JOB_NAME", "SOURCE_DATABASE", "SOURCE_TABLE", "TARGET_PATH"],
)

spark_context = SparkContext.getOrCreate()
glue_context = GlueContext(spark_context)
job = Job(glue_context)
job.init(args["JOB_NAME"], args)

source_frame = glue_context.create_dynamic_frame.from_catalog(
    database=args["SOURCE_DATABASE"],
    table_name=args["SOURCE_TABLE"],
)

cleaned_frame = (
    source_frame.toDF()
    .dropna()
    .withColumn("age", col("age").cast("int"))
    .dropna(subset=["age"])
    .withColumn("country", upper(col("country")))
)

print(f"Cleaned row count: {cleaned_frame.count()}")

cleaned_frame.write.mode("overwrite").parquet(args["TARGET_PATH"])
job.commit()
