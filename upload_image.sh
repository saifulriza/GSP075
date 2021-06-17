# upload image to the bucket
gsutil cp $FILE gs://$BUCKET_NAME/

# set permission to public
gsutil acl set -R public-read gs://$BUCKET_NAME/$FILE
