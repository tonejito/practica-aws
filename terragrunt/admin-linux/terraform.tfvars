aws_profile = "default"
# aws_profile = "ciencias"

aws_region = "us-east-2" # Ohio

vpc_id = "vpc-bc09d7d7" # us-east-2

#	ami_id = "ami-123456789abcdef00" # DUMMY
#	instance_type = "t4g.nano"

subnet_id = "subnet-8637f1ed" # us-east-2a (use2-az1)

dns_domain = "admin-linux.tonejito.cf"

ssh_key_file = "~/.ssh/keys/aws-ciencias_rsa.pub"

key_name = "aws-ciencias_rsa"

name = "admin-linux"

iam_path = "/admin-linux/"

tags = {
  Terraform = "True"
  Materia   = "AdminLinux"
  Semestre  = "2021"
  Proyecto  = "Proyecto final"
  Equipo    = "Equipo"
}

extra_iam_policies = [
  "arn:aws:iam::aws:policy/AmazonVPCReadOnlyAccess",
  "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
  "arn:aws:iam::aws:policy/AmazonRoute53ReadOnlyAccess",
  "arn:aws:iam::aws:policy/AmazonSESReadOnlyAccess",
  "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess",
]

s3_website_content = [
  {
    "Name" = "index.html",
    "Source" = "files/index.html",
    "ContentType" = "text/html",
  },
  {
    "Name" = "error.txt",
    "Source" = "files/error.txt",
    "Content-Type" = "text/plain",
  },
]

# Changing this list will force rebuild of
# - EC2 instances
# - IAM user / access_keys
# - DNS records

equipos = [
  "dns",
  "web",
  "mail",
  "database",
  "directory",
  "storage",
]

equipo = [
  {
    "name" = "dns",
    "instance_type" = "t4g.nano",
    "ami_id" = "ami-031dea1a744251b51" , # Amazon Linux 2 ARM64
  },
  {
    "name" = "web",
    "instance_type" = "t4g.nano",
    "ami_id" = "ami-060544b8209ee8136", # Debian 10 ARM64
  },
  {
    "name" = "mail",
    "instance_type" = "t4g.nano",
    "ami_id" = "ami-07f692d95b2b9c8c5", # CentOS 7 ARM64
  },
  {
    "name" = "database",
    "instance_type" = "t4g.micro",
    "ami_id" = "ami-01cdc9e8306344fe0", # CentOS 8 Stream ARM64
  },
  {
    "name" = "directory",
    "instance_type" = "t4g.nano",
    "ami_id" = "ami-05072f33892a49012", # Debian 11 ARM64
  },
  {
    "name" = "storage",
    "instance_type" = "t4g.nano",
    "ami_id" = "ami-0280c148473619d48", # Ubuntu 20.04 ARM64
  },
]

# aws ec2 describe-instance-attribute --instance-id ${INSTANCE_ID} --attribute disableApiTermination --region ${REGION}
# aws ec2 modify-instance-attribute --instance-id ${INSTANCE_ID} --no-disable-api-termination --region ${REGION}
# aws iam create-login-profile --user-name ${IAM_USER} --password ${IAM_PW} --no-password-reset-required
# aws iam update-login-profile --user-name ${IAM_USER} --password ${IAM_PW} --no-password-reset-required
# aws ses verify-email-identity --email-address user@example.com
