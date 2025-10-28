# AWS Terraform VPC, RDS, and Bastion Host Infrastructure

This repository contains Terraform and Terragrunt configurations to provision a secure AWS infrastructure that is well suited to serverless architecture. The setup includes a VPC, RDS instance, NAT Gateway (using [fkc-nat](https://registry.terraform.io/modules/RaJiska/fck-nat/aws/latest?tab=inputs)), Bastion Host, and associated security groups.

## Features

- **VPC**: Creates a Virtual Private Cloud with public, private, and database subnets.
- **RDS**: Provisions a MySQL database instance with secure configurations.
- **Bastion Host**: Deploys an EC2 instance for secure SSH access to private resources.
- **NAT Gateway**: Configures a NAT Gateway for outbound internet access from private subnets.
- **Security Groups**: Manages security groups for RDS, Bastion Host, and Lambda functions.
- **Key Pairs**: Generates and manages SSH key pairs for the Bastion Host.
- **Route53**: Manages DNS records for your domains.
- **AWS SES**: Send transactional emails from your application (user invitations, notifications, etc.).

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
    └── ses
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

### 6. Get all outputs

```bash
cd environments/dev
terragrunt run-all output
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

## AWS SES Email Setup (Send-Only)

This infrastructure includes AWS SES (Simple Email Service) configured for **sending emails** from your application. This is perfect for transactional emails like user invitations, password resets, notifications, etc.

### What This Does

- **Domain Identity Verification**: Automatically verifies your domain via Route53 DNS records
- **Email Authentication (SPF, DKIM, DMARC)**: Configures all three authentication methods to maximize deliverability and prevent spam
- **SMTP & API Access**: Enables both SMTP and AWS SDK/API sending methods
- **Works with Google Workspace**: Coexists perfectly with your existing email setup

### Why Email Authentication Matters

Without proper authentication, your emails are likely to end up in spam folders. This infrastructure automatically configures:

1. **SPF (Sender Policy Framework)**: Tells email providers which servers can send email from your domain
2. **DKIM (DomainKeys Identified Mail)**: Cryptographically signs your emails to prove they haven't been tampered with
3. **DMARC (Domain-based Message Authentication)**: Instructs email providers what to do if SPF/DKIM checks fail, and provides you with reports

**Real Impact**: Without DMARC, Gmail and other providers are significantly more likely to mark your emails as spam. With all three authentication methods properly configured, your legitimate emails will have much better inbox placement.

### Configuration

#### 1. Update Environment Variables

Edit `env.dev.hcl` and configure your domain:

```hcl
# AWS SES Configuration (Send-Only)
ses_domains = [
  {
    domain_name = "example.com"
    zone_id     = "Z0123456789ABCDEFGHIJ"  # Your Route53 zone ID
  }
]
```

#### 2. Deploy SES Infrastructure

Navigate to the SES directory and deploy:

```bash
cd environments/dev/ses
terragrunt init
terragrunt plan
terragrunt apply
```

This will create:
- SES domain identity with verification records
- Route53 TXT records for domain verification
- Route53 CNAME records for DKIM authentication (3 tokens)
- Route53 TXT record for SPF (if enabled)
- Route53 TXT record for DMARC policy
- Route53 MX record for custom MAIL FROM domain
- Route53 TXT record for MAIL FROM SPF

#### 3. Wait for Domain Verification

AWS will automatically verify your domain through the DNS records (usually takes 5-10 minutes):

```bash
# Check domain verification status
aws sesv2 get-email-identity --email-identity example.com
```

Look for `"VerificationStatus": "SUCCESS"` in the output. Example successful response:

```json
{
    "IdentityType": "DOMAIN",
    "VerifiedForSendingStatus": true,
    "DkimAttributes": {
        "SigningEnabled": true,
        "Status": "SUCCESS",
        "Tokens": [
            "abcd1234example5678",
            "efgh5678example9012",
            "ijkl9012example3456"
        ]
    },
    "MailFromAttributes": {
        "MailFromDomain": "mail.example.com",
        "MailFromDomainStatus": "SUCCESS",
        "BehaviorOnMxFailure": "USE_DEFAULT_VALUE"
    }
}
```

#### 3a. Verify Email Addresses for Testing (Sandbox Mode Only)

While in sandbox mode, you can only send emails to verified email addresses. Verify a test email:

```bash
# Create an email identity
aws sesv2 create-email-identity --email-identity user@example.com
```

AWS will send a verification email to that address. Click the link to verify. Then check the status:

```bash
# Check email verification status
aws sesv2 get-email-identity --email-identity user@example.com
```

Example successful response:

```json
{
    "IdentityType": "EMAIL_ADDRESS",
    "VerifiedForSendingStatus": true,
    "VerificationStatus": "SUCCESS",
    "DkimAttributes": {
        "SigningEnabled": true,
        "Status": "SUCCESS",
        "Tokens": [
            "abcd1234example5678",
            "efgh5678example9012",
            "ijkl9012example3456"
        ]
    },
    "MailFromAttributes": {
        "MailFromDomain": "mail.example.com",
        "MailFromDomainStatus": "SUCCESS",
        "BehaviorOnMxFailure": "USE_DEFAULT_VALUE"
    }
}
```

#### 4. Move Out of SES Sandbox (For Production)

By default, AWS SES starts in "sandbox mode" with these limitations:
- Can only send to verified email addresses
- Maximum 200 emails per 24 hours
- 1 email per second sending rate

**To send to any email address (required for production):**

1. Go to the [AWS SES Console](https://console.aws.amazon.com/ses/)
2. Click **Get Set Up** or go to **Account dashboard**
3. Click **Request production access**
4. Fill out the form:
   - Use case: Transactional emails (invitations, notifications)
   - Website URL: Your application URL
   - Describe how you handle bounces/complaints
   - Expected daily sending volume
5. Submit the request

Approval typically takes 24 hours. Until then, you can still test by verifying recipient email addresses.

#### 5. Create SMTP Credentials (For Application Use)

To send emails from your application:

**Option A: Using SMTP**

1. Go to the [AWS SES Console](https://console.aws.amazon.com/ses/)
2. Navigate to **Account dashboard** → **SMTP settings**
3. Click **Create SMTP credentials**
4. Save the SMTP username and password
5. Use these in your application:
   ```
   SMTP Server: email-smtp.eu-west-2.amazonaws.com
   Port: 587 (TLS) or 465 (SSL)
   Username: <your-smtp-username>
   Password: <your-smtp-password>
   ```

**Option B: Using AWS SDK**

Use the AWS SDK with your IAM credentials:
- Service: `sesv2` (Simple Email Service v2)
- Action: `SendEmail`
- Your application's IAM role needs the `ses:SendEmail` permission

### Sending Your First Email

**Test with AWS CLI (Sandbox Mode):**

While in sandbox mode, you can only send to verified email addresses:

```bash
# Send a test email
aws sesv2 send-email \
  --from-email-address noreply@example.com \
  --destination ToAddresses=user@example.com \
  --content 'Simple={Subject={Data="SES Test - Success!",Charset=utf8},Body={Text={Data="This email confirms your AWS SES setup is working perfectly!",Charset=utf8}}}'
```

Successful response:

```json
{
    "MessageId": "010b019a26cc4fe9-fb6c4a9e-0cb7-4a7d-be8f-247416dd6ab4-000000"
}
```

The `MessageId` confirms the email was accepted by SES and is being delivered.

**Test with AWS CLI (Production Mode):**

After production access is approved, you can send to any email address:

```bash
aws sesv2 send-email \
  --from-email-address noreply@example.com \
  --destination ToAddresses=user@example.com \
  --content 'Simple={Subject={Data="Test Email",Charset=utf8},Body={Text={Data="This is a test email",Charset=utf8}}}'
```

**Using Node.js SDK:**

```javascript
const { SESv2Client, SendEmailCommand } = require("@aws-sdk/client-sesv2");

const client = new SESv2Client({ region: "eu-west-2" });

const command = new SendEmailCommand({
  FromEmailAddress: "noreply@example.com",
  Destination: {
    ToAddresses: ["user@example.com"]
  },
  Content: {
    Simple: {
      Subject: { Data: "Invitation to Join" },
      Body: { 
        Html: { Data: "<h1>You're invited!</h1><p>Click here to join...</p>" }
      }
    }
  }
});

await client.send(command);
```

### Verification Commands Reference

These commands are useful for troubleshooting and monitoring your SES setup:

```bash
# Check domain verification and configuration
aws sesv2 get-email-identity --email-identity example.com

# Check email address verification
aws sesv2 get-email-identity --email-identity user@example.com

# List all verified identities
aws sesv2 list-email-identities

# Check account sending statistics
aws sesv2 get-account

# View sending statistics for last 14 days
aws sesv2 get-domain-statistics-report \
  --domain example.com \
  --start-date 2025-10-13T00:00:00Z \
  --end-date 2025-10-27T23:59:59Z

# Verify DMARC record is configured
dig TXT _dmarc.example.com
```

### Email Best Practices

1. **Use appropriate From addresses:**
   - `noreply@example.com` - for notifications
   - `invitations@example.com` - for user invitations
   - `support@example.com` - for support emails (if separate from Google Workspace)

2. **Handle bounces and complaints:**
   - Set up SNS notifications for bounces/complaints
   - Remove bounced emails from your sending list
   - Monitor your reputation in SES Console

3. **Warm up your sending:**
   - Start with low volume (100-200/day)
   - Gradually increase over 2-4 weeks
   - Maintain consistent sending patterns

4. **Monitor DMARC reports:**
   - DMARC reports are sent to the email configured in your terragrunt configuration
   - Reports show authentication success/failure rates
   - Help identify any unauthorized use of your domain
   - Typically sent daily or weekly by major email providers

### Troubleshooting

**Domain not verifying:**
- Check Route53 records are created correctly
- Wait 10-15 minutes for DNS propagation
- Run: `dig TXT _amazonses.example.com`
- Verify DKIM records: `dig TXT <token>._domainkey.example.com`
- Verify DMARC record: `dig TXT _dmarc.example.com`
- Verify MAIL FROM MX record: `dig MX mail.example.com`

**Still in Sandbox mode:**
- Submit production access request in SES Console (typically approved within 24 hours)
- While waiting, verify recipient email addresses for testing:
  ```bash
  aws sesv2 create-email-identity --email-identity recipient@example.com
  ```

**Email verification not working:**
- Check spam folder for verification email
- Resend verification:
  ```bash
  aws sesv2 create-email-identity --email-identity user@example.com
  ```
- If you get `AlreadyExistsException`, the identity exists but may need clicking the verification link

**Emails going to spam:**
- ✅ Ensure DKIM is verified (check SES Console)
- ✅ Ensure DMARC record exists: `dig TXT _dmarc.example.com`
- ✅ Verify SPF record includes amazonses.com
- Start with low volume and warm up your sending (100-200/day initially)
- Use consistent From addresses
- Include unsubscribe links
- Send only to engaged recipients
- Monitor bounce rates and complaints in SES Console

**DMARC warnings in AWS Console:**
- DMARC is automatically configured by this infrastructure
- If you see warnings, verify the `_dmarc.example.com` TXT record exists
- DMARC reports will be sent to the email configured in `dmarc_rua_email`
- Policy is set to "quarantine" by default (suspicious emails go to spam, not rejected)

**Authentication errors:**
- Verify SMTP credentials are correct
- Check IAM permissions for SDK usage
- Ensure your application's IAM role has `ses:SendEmail` permission

### Cost Considerations

SES sending costs:
- **First 62,000 emails/month**: FREE (if sent from EC2/Lambda)
- **After that**: $0.10 per 1,000 emails
- **Attachments**: $0.12 per GB

For 10,000 invitation emails/month: **FREE**

### Integration with Your Application

Since you're using this for user invitations, you'll want to:

1. **Store SMTP credentials in AWS Secrets Manager:**
   ```bash
   aws secretsmanager create-secret \
     --name ses-smtp-credentials \
     --secret-string '{"username":"AKIAXXXXX","password":"BXXXXXXX"}'
   ```

2. **Add IAM policy to your application's role:**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [{
       "Effect": "Allow",
       "Action": ["ses:SendEmail", "ses:SendRawEmail"],
       "Resource": "*"
     }]
   }
   ```

3. **Configure your email library** (examples for popular frameworks available in the documentation)





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

### SES (Simple Email Service)
- **Custom Module**: `modules/ses`
- **Features**: 
  - Send transactional emails from your application
  - Automatic domain verification via Route53
  - Complete email authentication (SPF, DKIM, DMARC) for maximum deliverability
  - DMARC reporting to monitor email authentication and detect spoofing attempts
  - SMTP and AWS SDK/API support
  - Cost-effective (62,000 free emails/month from EC2/Lambda)
  - Works alongside Google Workspace
  - Prevents emails from going to spam with proper authentication configuration

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Contact

For questions or support, please contact me via the social media links at [jonsully1.dev](https://jonsully1.dev/).