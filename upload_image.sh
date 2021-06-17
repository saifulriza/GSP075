# upload image to the bucket
gsutil cp $FILE gs://$BUCKET_NAME/

# set permission to public
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/$FILE
