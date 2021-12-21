# Create an EKS cluster
eksctl create cluster --vpc-private-subnets=subnet-08222a96b77ab1536,subnet-042542dd1ae409b0e --vpc-public-subnets=subnet-075c51df56318d550,subnet-0d5f8edd8761fb7ce

# Delete an EKS cluster
eksctl delete cluster --name cluster_name