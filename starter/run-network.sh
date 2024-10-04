aws cloudformation create-stack --stack-name udagram-network \
    --template-body file://network.yml   \
    --parameters file://network-parameters.json  \
    --capabilities "CAPABILITY_NAMED_IAM"  \
    --region=us-east-1
