# aurora_postgres_repo

-----------------
rds-logs-to-s3.py
-----------------
This script will copy logs from RDS to S3. RDS has logs retention of 3 days by default. 
This script push logs to S3 bucket for past 24 hours of logs for initial run. Subsequent run will push incremental RDS logs.

Install python and boto3.

Once you have set the keys using aws configure and downloaded python and boto3, you can shift to the folder where you have the downloaded python file and you can execute the below:

python <python-file-name> --bucketname (<bucket-name>) --rdsinstancename (<instance-name-of-the-logs-to-be-moved>) --region (<region-name-of-the-instance>) > backup_status.$(date "+%Y.%m.%d-%H.%M.%S").log

Here's an example:

python rdslogstos3.py --bucketname name --rdsinstancename instancename --region us-east-1 > backup_status.$(date "+%Y.%m.%d-%H.%M.%S").log

-----------------
daily_pgbadger.sh
-----------------
Based on argument given to this script will pull RDS logs from S3 bucket and generate pgbadger report.

Usage: ./pgbadger_daily.sh <bucket_name> <RDS instance name> <Date of report> <target_path_for_pgbadger_report>
