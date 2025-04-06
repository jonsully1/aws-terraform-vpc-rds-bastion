# AWS Terraform VPC, RDS, and Bastion Host Infrastructure

This repository contains Terraform and Terragrunt configurations to provision a secure AWS infrastructure that is well suited to serverless architecture. The setup includes a VPC, RDS instance, NAT Gateway (using [fkc-nat](https://registry.terraform.io/modules/RaJiska/fck-nat/aws/latest?tab=inputs)), Bastion Host, and associated security groups.

## Features

- **VPC**: Creates a Virtual Private Cloud with public, private, and database subnets.
- **RDS**: Provisions a MySQL database instance with secure configurations.
- **Bastion Host**: Deploys an EC2 instance for secure SSH access to private resources.
- **NAT Gateway**: Configures a NAT Gateway for outbound internet access from private subnets.
- **Security Groups**: Manages security groups for RDS, Bastion Host, and Lambda functions.
- **Key Pairs**: Generates and manages SSH key pairs for the Bastion Host.

## Repository Structure

```bash
.
├── README.md
├── env.dev.hcl
├── environments
│   └── dev
│       ├── bastion-host
│       │   └── terragrunt.hcl
│       ├── key-pairs
│       │   └── terragrunt.hcl
│       ├── nat-gateway
│       │   └── terragrunt.hcl
│       ├── rds
│       │   └── terragrunt.hcl
│       ├── root.hcl
│       ├── security-groups
│       │   └── terragrunt.hcl
│       └── vpc
│           └── terragrunt.hcl
└── modules
    ├── bastion-host
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── key-pairs
    │   ├── main.tf
    │   └── variables.tf
    ├── nat-gateway
    │   ├── main.tf
    │   └── variables.tf
    ├── rds
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── security-groups
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── vpc
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```
### Key Directories

- **`environments/dev`**: Contains Terragrunt configurations for the development environment.
- **`modules`**: Reusable Terraform modules for each infrastructure component.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- [Terragrunt](https://terragrunt.gruntwork.io/) >= 0.35.0
- AWS CLI configured with appropriate credentials and permissions.

## Usage

### 1. Clone the Repository

```bash
git clone https://github.com/your-repo/aws-terraform-vpc-rds-bastion.git
cd aws-terraform-vpc-rds-bastion
```

### 2. Configure Environment Variables
Add an `env.dev.hcl` in the root file with your specific inputs:

```bash
inputs = {
  infra_name                    = "your-infra-name"
  aws_region                    = "your-region"
  env                           = "dev"
  iac                           = "terragrunt"
  my_ip                         = "your-ip/32"
  bastion_host_private_key_name = "your-key-name"
}
```

### 3. Initialize
Navigate to the desired environment directory and initialize Terragrunt:

```bash
cd environments/dev
terragrunt run-all init
```

### 4. Plan
Run the following command to show what will be provisioned in your infrastructure:

```bash
terragrunt run-all plan -out=tfplan && terragrunt run-all show tfplan
```

### 5. Apply
Run the following command to provision the infrastructure:

```bash
terragrunt run-all apply tfplan
```

## Modules

### RDS
- **Source**: [terraform-aws-modules/rds/aws](https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest)
- **Features**: Provisions a MySQL database instance.

### Bastion Host
- **Source**: [terraform-aws-modules/ec2-instance/aws](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest)
- **Features**: Deploys an EC2 instance for secure SSH access.

### NAT Gateway
- **Source**: [RaJiska/fck-nat/aws](https://registry.terraform.io/modules/RaJiska/fck-nat/aws/latest)
- **Features**: Configures a NAT Gateway for private subnets.

### Security Groups
- **Source**: [terraform-aws-modules/security-group/aws](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest)
- **Features**: Manages security groups for RDS, Bastion Host, and Lambda.

### Key Pairs
- **Source**: [terraform-aws-modules/key-pair/aws](https://registry.terraform.io/modules/terraform-aws-modules/key-pair/aws/latest)
- **Features**: Generates and manages SSH key pairs.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Contact

For questions or support, please contact me via the social media links at [jonsully1.dev](https://jonsully1.dev/).