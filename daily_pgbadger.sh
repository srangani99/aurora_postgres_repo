#!/bin/bash
# Fetch logs from S3 bucket and execute pgbadger
#
#
#
# Usage: ./pgbadger_daily.sh <bucket_name> <RDS instance name> <2019-11-19> <target_path_for_pgbadger_report>
# -----------------------------------------------------------------------------
# validate number of arguments
if [ $# -ne 4 ]
then
  echo "Usage: ./pgbadger_daily.sh bucket_name rds_instance_name 2019-11-19"
  exit 1
fi

# remember the name of the input file
bucket_name=$1
rds_instance_name=$2
pgbadger_report_date=$3
target_path_for_pgbadger_report=$4
bucket_full_path=$1/$2/rdslogs_backup/error/
#validate date formate is correct

if [[ $pgbadger_report_date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
  then echo "Date ${pgbadger_report_date} is in valid format (YYYY-MM-DD)"
else echo "Date ${pgbadger_report_date} is in an invalid format (not YYYY-MM-DD)"
  exit 1
fi

# verify if console is connected to AWS CLI
echo "Verify if console is connected to AWS CLI"
aws configservice describe-delivery-channels
  if [ $? -ne 0 ]
    then echo "Error in connecting to AWS; check its permissions!"
    exit 1
  else echo "Connected to AWS cli"
  fi


  exists=$(aws s3 ls $bucket_name/$rds_instance_name)
  if [ -z "$exists" ]; then
    echo "S3 bucket does not exist"
  else
    echo "S3 bucket exists"
  fi

# Download s3 logs to target_path_for_pgbadger_report path location given in arguments

aws s3 sync s3://${bucket_name}/${rds_instance_name}/rdslogs_backup/error/ ${target_path_for_pgbadger_report} --exclude "*" --include "postgresql.log.${pgbadger_report_date}*"
if [ $? -ne 0 ]
  then echo "Error in rds logs download to local desk"
  exit 1
else echo "rds logs downloaded successfully"
fi

#execute pg_badger report

pgbadger -f stderr -p '%t:%r:%u@%d:[%p]:' ${target_path_for_pgbadger_report}/postgresql.log.${pgbadger_report_date}* -o pgbadger_{$rds_instance_name}_{$pgbadger_report_date}.html

#Push pgbadger report back to s3 bucket
