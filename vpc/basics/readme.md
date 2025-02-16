# create vpc
aws ec2 create-vpc --cidr-block 172.1.0.0/16 --region eu-west-2
# add costum tag (befor that get your vpc id and replace it with your vpc id)
aws ec2 create-tags --resources vpc-0a4a4d0f6e3a0b1c6 --tags Key=Name,Value=MyVPC --region eu-west-2 
# verify your tag if you want 
aws ec2 describe-vpcs --vpc-ids vpc-013e3ddf061aea8a6 --query "Vpcs[].Tags" --region eu-west-2 --output table

