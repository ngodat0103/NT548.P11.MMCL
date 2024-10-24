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
- `deploy-all.sh`: A script to automate the deployment of all CloudFormation stacks in order.

## Usage

### Step 1: Deploy the Stacks Using the Script

1. Navigate to the `CloudFormation` directory.
2. Make the script executable (if not already):
   ```sh
   chmod +x main.sh
   ```
3. Run the script to deploy all stacks:
   ```sh
   ./main.sh [region] [stack-name-prefix] [allow-ssh-ip] [instance-type]
   ```

   - `region`: (Optional) The AWS region to deploy the stacks. Default is `us-east-1`.
   - `stack-name-prefix`: (Optional) A prefix for the stack names. Default is `Group7`.
   - `allow-ssh-ip`: (Optional) The IP range allowed for SSH access. Default is `0.0.0.0/0`.
   - `instance-type`: (Optional) The EC2 instance type. Default is `t3.small`.

### Example Command

```sh
./main.sh us-west-2 CustomStackPrefix 192.168.1.0/24 t2.micro
```

This command will deploy the stacks in the `us-west-2` region with a custom stack name prefix, allowing SSH access from the `192.168.1.0/24` IP range, and using `t2.micro` as the instance type.

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

# AWS CloudFormation Infrastructure Setup

This project automates the setup of AWS infrastructure using CloudFormation templates. It creates a Virtual Private Cloud (VPC) with public and private subnets, and deploys EC2 instances in those subnets. The public instance can SSH into the private instance using a private key stored in an S3 bucket.

## Prerequisites

- **AWS CLI**: Ensure that the AWS CLI is installed and configured on your machine. You can install it using the following command:
  ```bash
  # For Linux
  sudo snap install aws-cli --classic

  # For macOS
  brew install awscli
  ```

- **AWS Configuration**: Configure your AWS CLI with your credentials:
  ```bash
  aws configure
  ```
  You will need to provide your AWS Access Key ID, Secret Access Key, default region name, and default output format.

- **Existing EC2 KeyPair**: Ensure you have an existing EC2 KeyPair in the AWS region you plan to deploy.

## Project Structure

- **CloudFormation Templates**:
  - `0-vpc.yml`: Sets up the VPC with public and private subnets.
  - `1-security.yml`: Configures security groups and network ACLs.
  - `2-public-route-table.yml`: Sets up the public route table.
  - `3-private-route-table.yml`: Sets up the private route table with a NAT gateway.
  - `4-ec2.yml`: Deploys EC2 instances in the VPC.

- **Scripts**:
  - `aws-s3.sh`: Checks for AWS CLI installation, verifies S3 bucket existence, and uploads YAML files to the bucket.
  - `deploy-all.sh`: Automates the deployment of all CloudFormation stacks.
  - `destroy.sh`: Deletes the CloudFormation stack and all associated resources.

## Deployment Instructions

### Step 1: Upload CloudFormation Templates to S3

1. Run the `aws-s3.sh` script to upload the CloudFormation templates to your S3 bucket:
   ```bash
   ./aws-s3.sh
   ```
   You will be prompted to enter your S3 bucket name. The script will check if the bucket exists and upload the templates.

### Step 2: Deploy the CloudFormation Stack

1. Run the `deploy-all.sh` script to deploy the CloudFormation stack:
   ```bash
   ./deploy-all.sh
   ```
   You will be prompted to enter various parameters such as the S3 bucket name, SSH private key, EC2 KeyPair name, AMI ID, instance type, and CIDR block for SSH access.

### Step 3: Monitor Stack Creation

- The script will automatically monitor the stack creation process and notify you upon successful completion.

### Step 4: Destroy the CloudFormation Stack

- To delete the stack and all resources, run the `destroy.sh` script:
  ```bash
  ./destroy.sh
  ```
  You will be prompted to enter the stack name to delete.

## Parameters Explanation

- **BucketName**: The name of the S3 bucket where the templates are stored.
- **sshPrivateKey**: The SSH private key for accessing EC2 instances, encoded in base64.
- **KeyName**: The name of the EC2 KeyPair for SSH access.
- **LatestAmiId**: The ID of the latest Amazon Machine Image (AMI) for EC2 instances.
- **InstanceType**: The type of EC2 instance to launch (e.g., t2.micro, t3.small).
- **AllowSSHIP**: The CIDR block allowed for SSH access to the EC2 instances.
- **Public Subnet**: Contains the public EC2 instance with an Elastic IP, allowing it to communicate with the internet.
- **Private Subnet**: Contains the private EC2 instance, which can only communicate with the internet through the NAT Gateway.
- **Internet Gateway**: Provides internet access to resources in the public subnet.
- **NAT Gateway**: Allows resources in the private subnet to access the internet without exposing them to inbound traffic.

## Conclusion

This setup provides a secure and scalable infrastructure on AWS, leveraging CloudFormation for automation and management. Ensure all parameters are correctly configured before deployment to avoid any issues.
