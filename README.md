# 🚀 Terraform AWS Demo Project

## Overview
This project provisions a highly available AWS infrastructure using Terraform. It deploys a production-ready environment including VPC, multi-AZ subnets, RDS, Application Load Balancer, and EC2 instances.

## Features
- **Multi-AZ VPC Architecture**
  - Public and private subnets across two availability zones
  - Internet Gateway for public internet access
  - NAT Gateway for private subnet outbound traffic
  
- **High Availability Components**
  - Application Load Balancer with cross-zone load balancing
  - Multi-AZ RDS deployment for database redundancy
  - Distributed EC2 instances across availability zones
  
- **Security Features**
  - Bastion host for secure SSH access to private instances
  - Network ACLs and Security Groups for traffic control
  - Private subnets for database and application tier

## Architecture Diagram

```plaintext
                                    Internet
                                       ↓
                                 [Internet Gateway]
                                       ↓
                    +----------------------------------------+
                    |                  VPC                    |
                    |  +---------------+    +---------------+ |
 Public Subnets     |  |     ALB      |    |    Bastion   | |
                    |  |   Subnet-1    |    |   Subnet-2   | |
                    |  +-------+-------+    +---------------+ |
                    |          ↓                             |
                    |  +-------+-------+    +---------------+ |
 Private Subnets    |  |    Backend   |    |   Backend    | |
                    |  |   Subnet-1    |    |   Subnet-2   | |
                    |  |   [EC2, RDS]  |    |    [EC2]     | |
                    |  +---------------+    +---------------+ |
                    +----------------------------------------+
```

## Prerequisites
- AWS Account with appropriate permissions
- Terraform (>= 1.0.0)
- AWS CLI configured with credentials
- SSH key pair for EC2 instance access

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/satishgonella2024/terraform-aws-demo.git
cd terraform-aws-demo
```

### 2. Configure AWS Credentials
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and preferred region
```

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Review and Apply Infrastructure
```bash
terraform plan    # Review the infrastructure changes
terraform apply   # Deploy the infrastructure
```

### 5. Access the Infrastructure
```bash
# Get the ALB DNS name
terraform output alb_dns_name

# Connect to bastion host (replace with your key path)
ssh -i terraform-key.pem ec2-user@<bastion-public-ip>
```

## Project Structure
```
terraform-aws-demo/
├── main.tf           # Provider configuration and main resources
├── variables.tf      # Input variables definition
├── outputs.tf        # Output values configuration
├── networking/       # VPC and networking components
│   ├── vpc.tf
│   ├── subnets.tf
│   └── security.tf
├── compute/          # EC2 and compute resources
│   ├── bastion.tf
│   └── backend.tf
├── database/         # RDS configuration
│   └── mysql.tf
├── loadbalancer/     # ALB and target groups
│   └── alb.tf
├── terraform.tfvars  # Variable values (git-ignored)
└── README.md         # Project documentation
```

## Security Best Practices
- All sensitive resources are deployed in private subnets
- Bastion host is the only entry point for SSH access
- Security groups follow the principle of least privilege
- Database credentials are managed through AWS Secrets Manager
- All data in transit is encrypted using TLS

## Monitoring and Maintenance
- CloudWatch metrics enabled for all resources
- CloudWatch alarms for critical metrics
- Access logs enabled for ALB and RDS
- Regular backup schedule for RDS instances

## Cost Optimization
- Use of t3.micro instances for development
- Auto-scaling based on demand
- RDS multi-AZ only in production
- NAT Gateway sharing across private subnets

## Next Steps
1. Implement Auto Scaling Groups (ASG) for backend servers
2. Enable HTTPS using AWS Certificate Manager
3. Set up S3 backend for Terraform state
4. Implement additional monitoring and alerting
5. Add disaster recovery procedures

## Contributing
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to your branch
5. Create a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details.