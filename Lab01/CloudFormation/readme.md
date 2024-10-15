# CloudFormation Templates for Modularized VPC and EC2 Instances

This repository contains AWS CloudFormation templates to set up a VPC with public and private subnets, and deploy EC2 instances in those subnets using a modular approach.

## Prerequisites

- AWS CLI installed and configured
- AWS CloudFormation permissions
- An existing EC2 KeyPair

## Files
- `CloudFormation/0-VPC.yml`: Creates a VPC with public and private subnets, route tables, and a NAT gateway.
- `CloudFormation/1-security.yml`: Sets up security groups and network ACLs.
- `CloudFormation/2-ec2.yml`: Deploys EC2 instances in the public and private subnets created by the VPC template.
## Usage

### Step 1: Deploy the Main Stack

1. Navigate to the `CloudFormation` directory.
2. Run the following command to create the main stack:

 ```sh
 aws cloudformation create-stack --stack-name my-main-stack --template-body file://main.yml --capabilities CAPABILITY_NAMED_IAM
 ```

Replace `<YourSSHPrivateKey>`, `<YourKeyPairName>`, and other parameters in the `0-vpc.yml` file with the appropriate values.

This command will deploy the network, security, and compute stacks as nested stacks, setting up the entire infrastructure in a modular way.

## High-Level Description

### 1. Security Stack (`1-security.yml`)

This template is responsible for setting up the security configurations for the AWS infrastructure. It includes:

- **Network ACLs**: Configures a public network ACL with rules to allow all inbound and outbound traffic.
- **Security Groups**: 
  - **Public Instance Security Group**: Allows SSH and ICMP traffic from any IP.
  - **Private Instance Security Group**: Allows SSH and ICMP traffic from the public subnet only.
- **Associations**: Associates the public subnet with the public network ACL.

### 2. EC2 Stack (`2-ec2.yml`)

This template handles the creation and configuration of EC2 instances within the VPC. It includes:

- **EC2 Instances**:
  - **Public EC2 Instance**: Launched in the public subnet with an associated Elastic IP for internet access.
  - **Private EC2 Instance**: Launched in the private subnet without direct internet access.
- **Elastic IP**: Allocates and associates an Elastic IP with the public EC2 instance for external connectivity.
- **Parameters**: Allows customization of instance types, key pairs, and security group IDs.

## Networking Diagram

Below is a conceptual networking diagram illustrating the setup:

```
+-------------------+       +-------------------+
|   Public Subnet   |       |   Private Subnet  |
|                   |       |                   |
|  +-------------+  |       |  +-------------+  |
|  |  EC2 Public |  |       |  | EC2 Private |  |
|  |  Instance   |  |       |  |  Instance   |  |
|  +-------------+  |       |  +-------------+  |
|       |           |       |                   |
|       | ElasticIP |       |                   |
+-------+-----------+       +-------------------+
        |                           |
        +---------------------------+
        |                           |
+-------v---------------------------v-------+
|                VPC                        |
|                                           |
|  +-----------------+   +----------------+ |
|  | Internet Gateway|   |   NAT Gateway  | |
|  +-----------------+   +----------------+ |
|                                           |
+-------------------------------------------+
```

- **Public Subnet**: Contains the public EC2 instance with an Elastic IP, allowing it to communicate with the internet.
- **Private Subnet**: Contains the private EC2 instance, which can only communicate with the internet through the NAT Gateway.
- **Internet Gateway**: Provides internet access to resources in the public subnet.
- **NAT Gateway**: Allows resources in the private subnet to access the internet without exposing them to inbound traffic.

This setup ensures a secure and scalable infrastructure, with clear separation between public and private resources.
