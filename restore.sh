#!/bin/sh -x

OPTIONS=`python3 /usr/local/bin/mongouri`
DB_NAME=`python3 /usr/local/bin/mongouri database`

IFS=","
for backup_name in ${BACKUP_NAMES}
do
  # Get latest backup
  if [ "$backup_name" = "latest" ]; then
    backup_name=$(aws s3 ls "s3://${S3_BUCKET}/${S3_PATH}" | tail -1 | awk '{print $NF}')
  fi

  # Download backup
  aws s3 cp "s3://${S3_BUCKET}/${S3_PATH%%/}/${backup_name}" "/backup/${backup_name}"
  # Decompress backup with progress
  cd /backup/ && tar -xzf $backup_name

  # Run backup
  if [ -n "${COLLECTIONS}" ]; then
    for collection in $COLLECTIONS
    do
      cmd="mongorestore -v ${OPTIONS} -c ${collection} /backup/${DB_NAME:+$BACKUP_PATH}/${collection}.bson"
      echo $cmd
      eval $cmd
    done
  else
    cmd="mongorestore -v ${OPTIONS} /backup/${DB_NAME:+$BACKUP_PATH}"
    echo $cmd
    eval $cmd
  fi

  # Delete backup files
  rm -rf /backup/*
done
