
aws cloudformation create-stack --stack-name udacity-web \
    --template-body file://udagram.yml   \
    --parameters file://udagram-parameters.json  \
    --capabilities "CAPABILITY_NAMED_IAM"  \
    --region=us-east-1
