#!/bin/bash

cd ../backend || exit 1

source .env

export TF_VAR_s3_bucket_name="$AWS_S3_BUCKET_NAME"

cd ../terraform || exit 1

if [ "$1" == "apply" ]; then

    terraform apply -auto-approve

elif [ "$1" == "destroy" ]; then

    terraform destroy -auto-approve

else

    terraform destroy -auto-approve
    terraform apply -auto-approve

fi