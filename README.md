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

## Connect to RDS via Bastion Host

### 1. Ensure bastion host is deployed

Set `bastion_enabled` to `true`:

*environments/dev/bastion-host/terragrunt.hcl*
```bash
...

inputs = merge(
  local.env_vars.inputs,
  {
    bastion_enabled           = true,  # Set to true to enable the bastion host
    ...
  }
)
```
### 2. Create a secure tunnel

Compile the following command from the terraform apply output and run from the project root in a new terminal:

```bash
ssh -i environments/dev/key-pairs/bastion-host-private-key.pem -L 3306:<rds_{mysql or postgres}_db_instance_endpoint>:3306 ec2-user@<bastion_host_public_ip>
```

example:
```bash
❯ ssh -i environments/dev/key-pairs/bastion-host-private-key.pem -L 3306:<rds_{mysql or postgres}_db_instance_endpoint>:3306 ec2-user@<bastion_host_public_ip>
Last login: Fri Oct  3 21:14:48 2025 from 95.214.229.91
   ,     #_
   ~\_  ####_        Amazon Linux 2
  ~~  \_#####\
  ~~     \###|       AL2 End of Life is 2025-06-30.
  ~~       \#/ ___
   ~~       V~' '->
    ~~~         /    A newer version of Amazon Linux is available!
      ~~._.   _/
         _/ _/       Amazon Linux 2023, GA and supported until 2028-03-15.
       _/m/'           https://aws.amazon.com/linux/amazon-linux-2023/

44 package(s) needed for security, out of 57 available
Run "sudo yum update" to apply all updates.
```

### 3. Connect to the database (creds in AWS Secrets Manager)

Open a 3rd terminal and connect.

#### Postgres

```bash
❯ psql -U postgres -h localhost -p 5432 postgres
Password for user postgres:
psql (15.8 (Postgres.app), server 14.13)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, compression: off)
Type "help" for help.

postgres=> \l
                                                 List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    | ICU Locale | Locale Provider |   Access privileges
-----------+----------+----------+-------------+-------------+------------+-----------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |            | libc            |
 rdsadmin  | rdsadmin | UTF8     | en_US.UTF-8 | en_US.UTF-8 |            | libc            | rdsadmin=CTc/rdsadmin
 template0 | rdsadmin | UTF8     | en_US.UTF-8 | en_US.UTF-8 |            | libc            | =c/rdsadmin          +
           |          |          |             |             |            |                 | rdsadmin=CTc/rdsadmin
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |            | libc            | =c/postgres          +
           |          |          |             |             |            |                 | postgres=CTc/postgres
(4 rows)

postgres=>
```

#### MySql

**NOTE:** On a few occasions I've hit the following error:

```bash
❯ mysql -h 127.0.0.1 -P 3306 -u admin -p
Enter password:
ERROR 2059 (HY000): Authentication plugin 'mysql_native_password' cannot be loaded: dlopen(/opt/homebrew/Cellar/mysql/9.3.0/lib/plugin/mysql_native_password.so, 0x0002): tried: '/opt/homebrew/Cellar/mysql/9.3.0/lib/plugin/mysql_native_password.so' (no such file), '/System/Volumes/Preboot/Cryptexes/OS/opt/homebrew/Cellar/mysql/9.3.0/lib/plugin/mysql_native_password.so' (no such file), '/opt/homebrew/Cellar/mysql/9.3.0/lib/plugin/mysql_native_password.so' (no such file)
```

Essentially needed to downgrade mysql client to 8.0:

```bash
brew install mysql@8.0
```

Then add 8.0 to the beginning of your PATH so it takes precedence:
```bash
echo 'export PATH="/opt/homebrew/opt/mysql@8.0/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

And connect:

```bash
❯ mysql -h 127.0.0.1 -P 3306 -u admin -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 44821
Server version: 8.0.41 Source distribution

Copyright (c) 2000, 2025, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| eac_school         |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.25 sec)
```

## Provide Internet Access to Lambdas

Ensure the NAT Gateway (`fck-nat`) is enabled:

*environments/dev/nat-gateway/terragrunt.hcl*
```bash
...

inputs = merge(
  local.env_vars.inputs,
  {
    nat_enabled = true  # Set to true when needed
    ...

   }
)
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