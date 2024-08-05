#!/bin/bash

# Variables
PROFILE_NAME="duyuqi-ozone"
ENDPOINT_URL="http://localhost:19878"
ACCESS_KEY="your-access-key"
SECRET_KEY="your-secret-key"
REGION="jxq-office"

# Configure AWS CLI
aws configure set aws_access_key_id $ACCESS_KEY --profile $PROFILE_NAME
aws configure set aws_secret_access_key $SECRET_KEY --profile $PROFILE_NAME
aws configure set region $REGION --profile $PROFILE_NAME
aws configure set output json --profile $PROFILE_NAME

# Add endpoint URL to config file
AWS_CONFIG_FILE=~/.aws/config
mkdir -p ~/.aws
if ! grep -q "\[profile $PROFILE_NAME\]" $AWS_CONFIG_FILE; then
    echo -e "[profile $PROFILE_NAME]\nregion = $REGION\noutput = json\ns3 =\n    endpoint_url = $ENDPOINT_URL" >> $AWS_CONFIG_FILE
else
    echo -e "s3 =\n    endpoint_url = $ENDPOINT_URL" >> $AWS_CONFIG_FILE
fi

# Verify the configuration by listing buckets
echo "default command:"
echo "aws s3 ls --profile $PROFILE_NAME"

echo "set endpoint url:"
echo "aws s3 ls --profile $PROFILE_NAME --endpoint $ENDPOINT_URL"

# echo "rm non empty bucket, we should delete all objects in the bucket first"
# for bucket in $(aws s3 ls --profile duyuqi-ozone --endpoint $ENDPOINT_URL | awk '{print $NF}'); do
# 	aws s3 rb --profile duyuqi-ozone --endpoint $ENDPOINT_URL s3://$bucket --force &> delete.$bucket.log & done
# done

# echo "rm a empty bucket"
# echo "aws s3 rm --profile duyuqi-ozone --endpoint $ENDPOINT_URL"