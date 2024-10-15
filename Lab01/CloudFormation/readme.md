# CloudFormation Templates for Modularized VPC and EC2 Instances

This repository contains AWS CloudFormation templates to set up a VPC with public and private subnets, and deploy EC2 instances in those subnets using a modular approach.

## Prerequisites

- AWS CLI installed and configured
- AWS CloudFormation permissions
- An existing EC2 KeyPair

## Files

- `CloudFormation/network.yml`: Creates a VPC with public and private subnets, route tables, and a NAT gateway.
- `CloudFormation/security.yml`: Sets up security groups and network ACLs.
- `CloudFormation/compute.yml`: Deploys EC2 instances in the public and private subnets created by the VPC template.
- `CloudFormation/0-vpc.yml`: Main stack that references the network, security, and compute stacks.

## Usage

### Step 1: Deploy the Main Stack

1. Navigate to the `CloudFormation` directory.
2. Run the following command to create the main stack:

 ```sh
 aws cloudformation create-stack --stack-name my-main-stack --template-body file://main.yml --capabilities CAPABILITY_NAMED_IAM
 ```

Replace `<YourSSHPrivateKey>`, `<YourKeyPairName>`, and other parameters in the `0-vpc.yml` file with the appropriate values.

This command will deploy the network, security, and compute stacks as nested stacks, setting up the entire infrastructure in a modular way.