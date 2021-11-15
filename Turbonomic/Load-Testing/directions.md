Environment:
- Running in AWS on EKS (Elastic Kubernetes Service)
- Region: us-east-2
- Network: six subnets (3 private/3 public) for redundancy
- Worker Nodes: One due to this being a demo environment and I'm not expecting there to be serious load.

Prerequisites:
1. Must have Docker installed
2. Must have Kubernetes installed
3. Must have AWS command-line installed

1. Set up AWS credentials on your localhost (Configuration basics - AWS Command Line Interface (amazon.com)). To authenticate, use the credentials in the Excel spreadsheet attached to this email.
2. Run the following command to update your localhost Kubeconfig: `aws eks --region us-east-2 update-kubeconfig --name gigaom-kubernetes-lab`. 
3. You can now run `kubectl get pods` and see that Vegeta is running.
4. Run the following command to execute a test against the running pod:

`kubectl exec vegeta-operator-7cdcf76d4c-xvzb2 -- sh -c "echo 'GET https://some_ip_address_or_hostname' | vegeta attack -rate=10 -duration=30s | tee results.bin | vegeta report"`