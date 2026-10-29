# AWS Infrastructure Provisioning Using Custom Terraform Modules

## Project Overview

This project provisions AWS infrastructure using Terraform and reusable custom modules. It demonstrates Infrastructure as Code (IaC), network segmentation, secure EC2 provisioning, S3 access through a VPC Gateway Endpoint, IAM permissions, and remote Terraform state management.

The infrastructure is designed to separate public-facing resources from private resources while maintaining controlled access to AWS services.

## Project Objectives

- Create a custom Amazon VPC.
- Configure public and private subnets.
- Create an Internet Gateway and NAT Gateway.
- Configure public and private route tables.
- Deploy a public EC2 web server.
- Deploy a private EC2 instance without a public IP address.
- Configure EC2 security groups and SSH key-pair authentication.
- Create a private S3 application bucket.
- Access S3 through an S3 Gateway VPC Endpoint.
- Configure an IAM role and least-privilege S3 permissions for the private EC2 instance.
- Store Terraform state remotely in Amazon S3.
- Configure state locking using DynamoDB and S3-native lock files.
- Organize the configuration into reusable Terraform modules.
- Document implementation, testing, screenshots, and cleanup procedures.

## Architecture

The intended architecture contains the following components:

```text
                         Internet
                            |
                     Internet Gateway
                            |
                 +----------------------+
                 |      Custom VPC      |
                 |     10.0.0.0/16      |
                 |                      |
                 |   Public Subnet      |
                 |    10.0.1.0/24       |
                 |          |           |
                 |   Public EC2 Web     |
                 |      Server          |
                 |          |           |
                 |     NAT Gateway      |
                 |          |           |
                 |   Private Subnet     |
                 |    10.0.2.0/24       |
                 |          |           |
                 |    Private EC2       |
                 |          |           |
                 |   S3 Gateway VPC     |
                 |      Endpoint        |
                 +----------|-----------+
                            |
                     Amazon S3 Bucket
```

### Remote Terraform State Architecture

```text
Terraform CLI (Local Computer)
             |
             v
     Amazon S3 State Bucket
             |
             +---- Terraform state file
             |
             +---- State versioning
             |
             +---- S3-native lock file
             |
             +---- DynamoDB state-locking table
```

The S3 bucket and DynamoDB table are provisioned separately through the `bootstrap` configuration before initializing the main infrastructure configuration.

## Technology Stack

| Technology | Purpose |
|---|---|
| Terraform | Infrastructure as Code |
| AWS VPC | Network isolation |
| Public and private subnets | Network segmentation |
| Internet Gateway | Internet connectivity for public resources |
| NAT Gateway | Outbound internet access for private resources |
| Amazon EC2 | Compute instances |
| Amazon Linux 2023 | EC2 operating system |
| Amazon S3 | Application storage and remote state |
| S3 Gateway VPC Endpoint | Private network access to S3 |
| AWS IAM | Roles and access policies |
| Security Groups | Instance-level traffic control |
| DynamoDB | Terraform state-locking table |
| Terraform modules | Reusable infrastructure components |
| PowerShell | Local command-line execution |
| Visual Studio Code | Terraform development environment |
| Git and GitHub | Version control and project documentation |

## Infrastructure Details

### 1. Custom VPC

- CIDR block: `10.0.0.0/16`
- DNS support enabled.
- DNS hostnames enabled.
- Internet Gateway attached to the VPC.
- Separate public and private route tables.

### 2. Public Subnet

- CIDR block: `10.0.1.0/24`
- Public IP assignment enabled.
- Associated with the public route table.
- Default route directs internet traffic to the Internet Gateway.
- Hosts the public web server.

### 3. Private Subnet

- CIDR block: `10.0.2.0/24`
- Public IP assignment disabled.
- Associated with the private route table.
- Default internet-bound route uses the NAT Gateway.
- Hosts the private EC2 instance.

### 4. NAT Gateway

The NAT Gateway allows instances in the private subnet to initiate outbound internet connections without assigning them public IPv4 addresses.

The NAT Gateway is placed in the public subnet and uses an Elastic IP address.

**Cost note:** NAT Gateways incur hourly and data-processing charges. Remove the lab infrastructure when it is no longer needed.

### 5. EC2 Instances

**Public web server**
- Uses Amazon Linux 2023.
- Runs NGINX through EC2 user data.
- Serves a simple HTML page.
- Allows HTTP traffic on port 80.
- Restricts SSH access to the configured administrator CIDR.

**Private EC2 instance**
- Uses Amazon Linux 2023.
- Has no public IP address.
- Uses an IAM instance profile.
- Has permissions to list and access objects in the application S3 bucket.
- Is configured with an SSM IAM policy for potential Session Manager access.

Session Manager access also requires a working SSM Agent, appropriate network connectivity, and successful Systems Manager registration. The IAM policy alone does not guarantee that the instance is reachable through Session Manager.

### 6. Amazon S3 Application Bucket

The application bucket is configured with:

- A generated suffix to help ensure globally unique naming.
- S3 Block Public Access.
- Bucket versioning.
- Server-side encryption using AES-256.
- IAM permissions restricted to the application bucket.

### 7. S3 Gateway VPC Endpoint

The S3 Gateway Endpoint is associated with the private route table. It provides a private routing path to Amazon S3 without requiring S3 traffic to travel through a public internet gateway or NAT Gateway.

The endpoint policy restricts the S3 actions and resources allowed through the endpoint. The EC2 IAM role separately grants the required S3 permissions.

### 8. Remote Terraform State and Locking

The bootstrap configuration creates the remote state infrastructure.

| Resource | Name |
|---|---|
| S3 state bucket | `terraform-aws-exam-state-f84f7133` |
| State object key | `terraform-aws-exam/terraform.tfstate` |
| AWS region | `us-east-1` |
| DynamoDB locking table | `terraform-aws-exam-locks` |
| State encryption | Enabled |
| S3 versioning | Enabled |
| S3-native locking | Enabled |

The DynamoDB locking parameter is deprecated in newer Terraform AWS backend implementations, but it is retained here to meet the examination requirement. S3-native lock-file support is also enabled.

## Project Directory Structure

```text
Terafrom/
|
|-- README.md
|-- .gitignore
|
|-- bootstrap/
|   |-- provider.tf
|   |-- s3.tf
|   |-- dynamodb.tf
|   |-- outputs.tf
|   |-- .terraform.lock.hcl
|   `-- terraform.tfstate       # Never commit
|
`-- main/
    |-- provider.tf
    |-- terraform.tf
    |-- variables.tf
    |-- terraform.tfvars.example
    |-- main.tf
    |-- outputs.tf
    |-- .terraform.lock.hcl
    |
    `-- modules/
        |-- vpc/
        |   |-- main.tf
        |   |-- variables.tf
        |   `-- outputs.tf
        |
        |-- ec2/
        |   |-- main.tf
        |   |-- variables.tf
        |   `-- outputs.tf
        |
        |-- s3/
        |   |-- main.tf
        |   |-- variables.tf
        |   `-- outputs.tf
        |
        `-- vpc-endpoint/
            |-- main.tf
            |-- variables.tf
            `-- outputs.tf
```

The structure above describes the intended organization. Keep only files and directories that actually exist in your repository.

## Prerequisites

Before deployment, install and configure:

1. Terraform CLI.
2. AWS CLI.
3. Visual Studio Code.
4. Git.
5. An AWS account with sufficient permissions.
6. AWS credentials configured locally using a secure method.
7. A local SSH private key and its corresponding public key.

Verify the installations:

```powershell
terraform version
aws --version
git --version
```

Verify AWS identity:

```powershell
aws sts get-caller-identity
```

Do not put AWS access keys or secret keys inside Terraform files or commit them to GitHub.

## Deployment Guide

Run the commands from PowerShell in the appropriate directory.

### Step 1: Prepare the SSH public key

The root configuration expects a public key at:

```text
~/.ssh/terraform-exam-key.pub
```

If you already have a suitable PEM private key, derive its public key. For example, if your key is stored in Downloads:

```powershell
ssh-keygen -y -f "$HOME\Downloads\om.pem" |
    Set-Content -Encoding ascii "$HOME\.ssh\terraform-exam-key.pub"
```

Replace `om.pem` with your actual PEM filename.

Never commit the private PEM file. Use a key whose matching private key you control.

### Step 2: Initialize the bootstrap configuration

```powershell
cd C:\Onkar-Workspace\projects\DEVOPS\Terafrom\bootstrap
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Review the plan before applying:

```powershell
terraform apply
```

This step provisions the S3 remote-state bucket and DynamoDB table. If these resources already exist and are managed by this configuration, do not apply the bootstrap configuration unnecessarily.

### Step 3: Configure the main project

```powershell
cd C:\Onkar-Workspace\projects\DEVOPS\Terafrom\main
Copy-Item .\terraform.tfvars.example .\terraform.tfvars
```

Edit `terraform.tfvars` and set your actual public IPv4 address in CIDR notation for SSH access:

```hcl
project_name     = "terraform-exam"
aws_region       = "us-east-1"
instance_type    = "t3.micro"
ssh_allowed_cidr = "YOUR_PUBLIC_IP/32"
```

Replace `YOUR_PUBLIC_IP` with your own public IPv4 address. Do not commit `terraform.tfvars`.

### Step 4: Initialize the remote backend

```powershell
terraform init
```

If Terraform reports that the backend configuration has changed, inspect whether a local state or existing remote state needs migration before choosing a reconfiguration or migration option.

### Step 5: Format and validate

```powershell
terraform fmt -recursive
terraform validate
```

Expected validation result:

```text
Success! The configuration is valid.
```

### Step 6: Review the infrastructure plan

```powershell
terraform plan -out=tfplan
terraform show tfplan
```

Review the resources, security settings, and expected costs before deployment.

### Step 7: Apply the reviewed plan

Only after confirming the plan is correct:

```powershell
terraform apply tfplan
```

Wait for Terraform to finish. If the command fails, inspect the error and current state before retrying.

### Step 8: Inspect outputs and state

```powershell
terraform output
terraform state list
```

Expected outputs include the VPC ID, subnet IDs, web server instance ID, web server public IP, private instance ID, application bucket name, and S3 endpoint ID.

Actual values are generated during deployment.

## Verification and Testing

Perform these tests after a successful deployment.

### 1. Verify the web server

Retrieve the public IP:

```powershell
terraform output -raw web_public_ip
```

Open the resulting IP address in a browser using HTTP:

```text
http://YOUR_WEB_SERVER_PUBLIC_IP
```

The page should display the Terraform infrastructure test message once the instance has booted and NGINX is running.

### 2. Verify AWS resources

Check the VPC and instances in the AWS Management Console:

- VPC Console
- EC2 Console
- S3 Console
- IAM Console
- VPC Endpoints
- DynamoDB Console

Confirm that the private EC2 instance has no public IP address.

### 3. Verify S3 access from the private EC2 instance

Use an approved access method, such as AWS Systems Manager Session Manager, after confirming that the private instance is registered and reachable.

Check the AWS CLI and IAM role:

```bash
aws sts get-caller-identity
aws s3 ls s3://YOUR_APPLICATION_BUCKET_NAME
```

Test object upload and download with a harmless test file:

```bash
echo "S3 endpoint verification" > endpoint-test.txt
aws s3 cp endpoint-test.txt s3://YOUR_APPLICATION_BUCKET_NAME/endpoint-test.txt
aws s3 cp s3://YOUR_APPLICATION_BUCKET_NAME/endpoint-test.txt downloaded-test.txt
cat downloaded-test.txt
```

Replace `YOUR_APPLICATION_BUCKET_NAME` with the actual bucket name.

Verify the endpoint is associated with the private route table. For a stronger test, inspect the route table and endpoint configuration in the AWS Console. A successful S3 CLI request alone does not prove that traffic used the VPC endpoint.

### 4. Verify remote state

Check whether the state object exists:

```powershell
aws s3 ls s3://terraform-aws-exam-state-f84f7133/terraform-aws-exam/
```

Inspect the locking table:

```powershell
aws dynamodb describe-table --table-name terraform-aws-exam-locks --region us-east-1
```

Do not manually edit or delete the remote Terraform state object or active lock records.

## Security Best Practices

- Store Terraform state remotely in a protected S3 bucket.
- Enable S3 versioning and server-side encryption.
- Keep S3 Block Public Access enabled.
- Use IAM roles instead of hardcoded credentials.
- Restrict SSH access to a trusted administrator IP.
- Avoid exposing SSH to `0.0.0.0/0`.
- Keep private EC2 instances without public IP addresses.
- Apply least-privilege IAM permissions.
- Keep private keys, credentials, state files, and sensitive variable files out of Git.
- Review security group rules and Terraform plans before applying.
- Use approved session access methods for private instances.
- Rotate any AWS credentials that may have been exposed.

## GitHub Upload

From the project root, create or update `.gitignore` with these entries:

```gitignore
# Terraform working files
**/.terraform/*
**/terraform.tfstate
**/terraform.tfstate.*
**/crash.log
**/crash.*.log
**/tfplan
**/terraform.tfplan

# Sensitive variable files
**/terraform.tfvars
**/*.auto.tfvars

# Private keys and credentials
*.pem
*.key
*.ppk
.aws/
```

Keep `.terraform.lock.hcl` files under version control to preserve provider selections.

Review your staged files carefully before committing:

```powershell
cd C:\Onkar-Workspace\projects\DEVOPS\Terafrom
git init
git status
git add README.md .gitignore bootstrap main
git status
```

Confirm that no state files, private keys, credentials, or sensitive variable files are staged. Then commit:

```powershell
git commit -m "Add modular AWS Terraform infrastructure project"
```

Create an empty repository on GitHub and follow its instructions to connect and push your local repository. For example:

```powershell
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```

Replace the example GitHub username and repository with your own. If a remote is already configured, inspect it with `git remote -v` before adding another.

## Screenshots for the Practical Examination

Capture genuine screenshots of the completed implementation. Recommended evidence includes:

1. Terraform project folder structure in VS Code.
2. Bootstrap S3 bucket and DynamoDB table.
3. Successful `terraform init`.
4. Successful `terraform validate`.
5. Terraform plan output.
6. VPC and subnet configuration.
7. Public and private route tables.
8. Internet Gateway and NAT Gateway.
9. Public EC2 web server and browser output.
10. Private EC2 instance showing no public IP.
11. S3 Gateway VPC Endpoint and associated private route table.
12. IAM role and S3 policy.
13. Successful S3 access from the private EC2 instance.
14. Remote Terraform state object in S3.
15. Successful Terraform outputs and resource state list.
16. GitHub repository containing the README and Terraform module code.

Only include screenshots of steps that were actually completed successfully. Hide AWS account details and any sensitive information where appropriate.

## Cost Management and Cleanup

AWS resources may incur charges, especially NAT Gateways, Elastic IP addresses, and running EC2 instances. Review your AWS billing dashboard during the lab.

When you no longer need the infrastructure, first remove the main infrastructure:

```powershell
cd C:\Onkar-Workspace\projects\DEVOPS\Terafrom\main
terraform destroy
```

Review the destruction plan and confirm before proceeding. Keep the bootstrap backend resources until the main infrastructure has been destroyed and you no longer need its state.

After the main infrastructure has been safely removed, the bootstrap resources can be destroyed separately if required:

```powershell
cd C:\Onkar-Workspace\projects\DEVOPS\Terafrom\bootstrap
terraform destroy
```

The bootstrap S3 bucket has `prevent_destroy = true`, so Terraform will block its destruction until that lifecycle protection is deliberately removed from the configuration. Do not remove the protection or delete the state bucket until you have confirmed that the main state is no longer needed and backed up any required evidence.

## Learning Outcomes

Through this project, I practiced:

- Designing AWS networking with public and private subnets.
- Implementing route tables, Internet Gateway, and NAT Gateway.
- Provisioning EC2 instances through Terraform.
- Creating reusable custom Terraform modules.
- Managing IAM roles and permissions.
- Configuring an S3 Gateway VPC Endpoint.
- Implementing remote state storage and state locking.
- Validating, planning, and applying Infrastructure as Code.
- Following security, documentation, and version-control practices.

## Conclusion

This project demonstrates a modular Infrastructure as Code approach for provisioning AWS resources with Terraform. It combines network segmentation, compute provisioning, controlled S3 access, IAM permissions, and remote state management in a documented and reproducible workflow.

**Project status:** Update this README with the actual deployment status, resource outputs, verified screenshots, and GitHub repository link after completing and testing the infrastructure.



![AWS Terraform Infrastructure Architecture](/images/vscode.png)


![AWS Terraform Infrastructure Architecture](/images/aws.png)

## Author

**Onkar Hol**

GitHub: https://github.com/onkar0602

Focus areas: AWS Cloud, Linux, Networking, Terraform, DevOps, Infrastructure as Code.
