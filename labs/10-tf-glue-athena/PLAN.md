Build a small AWS Glue learning project from scratch.

Goal:
Learn the core AWS Glue workflow in isolation, without mixing in unrelated services or complex architecture.

Project flow:

CSV file
↓
Amazon S3
↓
AWS Glue Crawler
↓
AWS Glue Data Catalog
↓
Amazon Athena

Then extend it with:

Raw CSV in S3
↓
AWS Glue ETL Job
↓
Clean / transform data
↓
Parquet output in S3
↓
Glue Data Catalog
↓
Athena

Use Terraform for the infrastructure.

Requirements

1. Create a simple local CSV dataset:

id,name,country,age
1,Alice,Germany,31
2,Bob,UK,28
3,Charlie,France,35
4,David,Germany,42
5,Eve,France,27

1. Create an S3 bucket with this structure:

s3://<bucket>/
├── raw/
│ └── users.csv
└── processed/

1. Upload the CSV file to:

raw/users.csv

For upload part just create a bash script file that i can run it locally.

1. Create a Glue Data Catalog database:

glue_learning

1. Create an IAM role for the Glue crawler.

Give it only the permissions required to:

- read the raw S3 data
- access the Glue Data Catalog

1. Create a Glue Crawler.

Crawler target:

s3://<bucket>/raw/

The crawler should:

- inspect the CSV
- infer the schema
- create a table inside the glue_learning database

1. After the crawler finishes, verify the generated Glue table and schema.

Expected logical schema:

id bigint
name string
country string
age bigint

1. Query the table using Athena.

Test queries:

SELECT * FROM users;

SELECT *
FROM users
WHERE age > 30;

SELECT country, COUNT(*) AS users
FROM users
GROUP BY country
ORDER BY users DESC;

1. Once the basic crawler/catalog flow works, add a Glue ETL job.

The ETL job should:

- read the CSV data from raw/
- remove rows with null values
- make sure age is an integer
- convert country values to uppercase
- write the result as Parquet
- store the result under processed/

Expected flow:

raw/users.csv
↓
Glue ETL
↓
processed/users/

1. Organize the processed data using a simple partition:

processed/
└── country=GERMANY/
└── country=FRANCE/
└── country=UK/

If partitioning makes the first version unnecessarily complicated, implement it after the basic Parquet conversion works.

1. Create or update a Glue table for the processed Parquet dataset.

2. Query the processed data with Athena.

Example:

SELECT *
FROM processed_users;

SELECT country, AVG(age)
FROM processed_users
GROUP BY country;

Project structure

Use something close to:

aws-glue-lab/
├── README.md
├── data/
│ └── users.csv
├── terraform/
│ ├── main.tf
│ ├── variables.tf
│ ├── outputs.tf
│ ├── s3.tf
│ ├── iam.tf
│ ├── glue.tf
│ └── athena.tf
└── glue/
└── transform.py

Keep the Terraform simple and readable.

Learning objectives

While building it, explain the purpose of each component:

- S3 stores the real data
- Glue Crawler discovers the schema
- Glue Data Catalog stores metadata
- Glue Database groups metadata tables
- Glue Table describes data stored elsewhere
- Athena uses the Glue Data Catalog to query S3
- Glue ETL jobs transform data
- Parquet is more efficient for analytics than CSV
- partitions reduce the amount of data scanned

Important constraints

- Keep this a learning project.
- Do not introduce Lambda.
- Do not introduce Step Functions.
- Do not introduce EventBridge.
- Do not introduce Kubernetes.
- Do not introduce complex CI/CD.
- Do not over-engineer Terraform.
- Prefer the smallest working implementation.
- Use least-privilege IAM where reasonable.
- Explain important AWS Glue concepts while implementing them.

Implementation order

Phase 1: -> done
S3 + CSV

Phase 2: -> done
Glue Database + Crawler

Phase 3: -> done
Glue Catalog + Athena query

Phase 4: -> done
Glue ETL job

Phase 5: -> done
CSV → Parquet

Phase 6: -> done
Partitioned Parquet + Athena queries

At the end, update README.md with:

- architecture diagram
- deployment commands
- how to run the crawler
- how to run the Glue job
- Athena queries
- explanation of what Glue is doing at every stage

Do not build everything at once.

Implement one phase at a time, verify it works, and explain what changed before moving to the next phase.
