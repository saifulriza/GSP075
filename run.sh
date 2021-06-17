#!bin/bash

export BUCKET_NAME=$(gcloud config get-value project)-bucket
export FILE=img/sign.jpg
export API_KEY=$1

#set permisson to file
chmod +x create_bucket.sh upload_image.sh

# create bucket
./create_bucket.sh

# upload image
./upload_image.sh

#make ocr req file
cat << EOF > ocr-request.json
{
  "requests": [
      {
        "image": {
          "source": {
              "gcsImageUri": "gs://$BUCKET_NAME/sign.jpg"
          }
        },
        "features": [
          {
            "type": "TEXT_DETECTION",
            "maxResults": 10
          }
        ]
      }
  ]
}
EOF


# make request and save the response
curl -s -X POST -H "Content-Type: application/json" --data-binary @ocr-request.json  https://vision.googleapis.com/v1/images:annotate?key=$API_KEY -o ocr-response.json

# make translation request
cat << EOF > translation-request.json
{
  "q": "your_text_here",
  "target": "en"
}
EOF

# Extract the image text from the previous step and copy it into a new translation-request.json
STR=$(jq .responses[0].textAnnotations[0].description ocr-response.json) && STR="${STR//\"}" && sed -i "s|your_text_here|$STR|g" translation-request.json

# get the translation response
curl -s -X POST -H "Content-Type: application/json" --data-binary @translation-request.json https://translation.googleapis.com/language/translate/v2?key=$API_KEY -o translation-response.json

# Show the response
cat translation-response.json

# make NL
cat << EOF > nl-request.json
{
  "document":{
    "type":"PLAIN_TEXT",
    "content":"your_text_here"
  },
  "encodingType":"UTF8"
}
EOF

# copy the translated text into the content block of the Natural Language API request
STR=$(jq .data.translations[0].translatedText  translation-response.json) && STR="${STR//\"}" && sed -i "s|your_text_here|$STR|g" nl-request.json

# Analize
curl "https://language.googleapis.com/v1/documents:analyzeEntities?key=$API_KEY" \
  -s -X POST -H "Content-Type: application/json" --data-binary @nl-request.json

# finish
echo 'FINISHED!'