# month-one-assessment
TechCorp AWS Terraform Infrastructure
Project Overview
This project deploys a highly available and secure web application infrastructure on AWS using Terraform.

The infrastructure includes:
•	A custom VPC with public and private subnets
•	Internet Gateway and NAT Gateways
•	Bastion host for secure SSH access
•	Two web servers running Apache
•	One PostgreSQL database server
•	Application Load Balancer distributing traffic to the web servers
•	Security groups controlling access between components
This architecture provides high availability, network isolation, and secure administrative access.

Architecture
The deployed infrastructure looks like this:
Internet
↓
Application Load Balancer
↓
Public Subnets
•	Bastion Host
Private Subnets
•	Web Server 1
•	Web Server 2
•	Database Server

Prerequisites
Before deploying the infrastructure, make sure you have:
•	AWS account
•	AWS CLI installed and configured (aws configure)
•	Terraform installed
•	An AWS key pair created
•	Your public IP address for bastion SSH access

Project Structure
terraform-assessment/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
├── terraform.tfstate
├── README.md
├── user_data/
│   ├── web_server_setup.sh
│   └── db_server_setup.sh
└── evidence/

Deployment Steps
Follow these steps to deploy the infrastructure.
1. Initialize Terraform
This command downloads required providers and prepares Terraform.
terraform init
Terraform initialization prepares the working directory before any infrastructure operations can occur. (HashiCorp Developer)

2. Review the Infrastructure Plan
This command shows what Terraform will create before deployment.
terraform plan
The plan command previews the changes Terraform will make to the infrastructure. (Medium)

3. Deploy the Infrastructure
Run:
terraform apply
Type:
yes
Terraform will then create the AWS resources defined in the configuration. 

Accessing the Infrastructure
After deployment you can access:
Bastion Host
SSH into the bastion host using its public IP.
ssh ec2-user@3.236.186.231
Web Servers
Access the web servers through the Application Load Balancer URL.
Example:
techcorp-alb-472432770.us-east-1.elb.amazonaws.com
PostgreSQL Database
From the bastion host SSH into the database server and run:
sudo -u postgres psql

Destroy Infrastructure
To delete all resources created by Terraform run:
terraform destroy
This command removes all infrastructure resources defined in the Terraform configuration. (Medium)

Deployment Evidence
Screenshots showing the successful deployment are included in the evidence/ folder.
These include:
•	Terraform plan output
•	Terraform apply completion
•	AWS console showing resources
•	Application Load Balancer web page
•	SSH access through bastion host
•	SSH access to web server
•	SSH access to database server
•	PostgreSQL prompt on database server

Author
Chukwuere Emmanuel Chima
TechCorp Assessment
