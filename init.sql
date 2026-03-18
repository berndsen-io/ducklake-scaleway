INSTALL ducklake;
INSTALL postgres;

-- Read connection details from Terraform outputs
SET VARIABLE postgres_host = (SELECT ducklake_postgres_host FROM read_json('data/outputs.json'));
SET VARIABLE postgres_port = (SELECT ducklake_postgres_port FROM read_json('data/outputs.json'));
SET VARIABLE s3_bucket_endpoint = (SELECT s3_bucket_endpoint FROM read_json('data/outputs.json'));
SET VARIABLE s3_data_path = (SELECT s3_data_path FROM read_json('data/outputs.json'));
SET VARIABLE s3_region = (SELECT s3_region FROM read_json('data/outputs.json'));

CREATE OR REPLACE SECRET s3_secret (
    TYPE s3,
    PROVIDER config,
    ENDPOINT 's3.' || getvariable('s3_region') || '.scw.cloud',
    KEY_ID getenv('SCW_ACCESS_KEY'),
    SECRET getenv('SCW_SECRET_KEY'),
    REGION getvariable('s3_region'),
    URL_STYLE 'path',
    USE_SSL true
);

CREATE OR REPLACE SECRET postgres_secret (
    TYPE postgres,
    HOST getvariable('postgres_host'),
    PORT CAST(getvariable('postgres_port') AS INTEGER),
    DATABASE 'ducklake_catalog',
    USER 'ducklake',
    PASSWORD getenv('TF_VAR_postgres_db_password')
);

CREATE SECRET ducklake_secret (
    TYPE ducklake,
    METADATA_PATH '',
    DATA_PATH getvariable('s3_data_path') || '/',
    METADATA_PARAMETERS MAP {'TYPE': 'postgres', 'SECRET': 'postgres_secret'}
);

ATTACH 'ducklake:ducklake_secret' AS ducklake;
USE ducklake;
SELECT 'DuckLake is ready' AS status;
