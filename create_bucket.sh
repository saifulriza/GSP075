# -c is class storage : STANDARD|NEARLINE|COLDLINE|ARCHIVE
# read : https://cloud.google.com/storage/docs/storage-classes
gsutil mb -c STANDARD gs://$BUCKET_NAME
