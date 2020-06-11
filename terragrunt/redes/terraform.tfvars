aws_profile = "ciencias"

aws_region = "us-east-1" # Virginia

vpc_id = "vpc-fe5b4584" # us-east-1

subnet_id = "subnet-978c4ef1" # us-east-1b (use1-az1)

# https://wiki.debian.org/Cloud/AmazonEC2Image/Buster
ami_id = "ami-0f31df35880686b3f" # Debian 10 (us-east-1)

dns_domain = "redes.tonejito.cf"

ssh_key_file = "~/.ssh/keys/aws-ciencias_rsa.pub"

key_name = "aws-ciencias_rsa"

instance_type = "t2.nano"

name = "redes"

iam_path = "/redes/"

tags = {
  Terraform = "True"
  Materia   = "Redes"
  Semestre  = "2020-2"
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
    "ContentType" = "text/plain",
  },
]

# Changing this list will force rebuild of
# - EC2 instances
# - IAM user / access_keys
# - DNS records

equipo = [
  "vpn",         # 0
  "tunnel",      # 1
  "files",       # 2
  "proxy",       # 3
  "monitoring",  # 4
  "mail",        # 5
  "access",      # 6
  "python",      # 7
  "java",        # 8
  "db-master",   # 9
  "db-slave",    # 10
]

# aws ec2 describe-instance-attribute --instance-id ${INSTANCE_ID} --attribute disableApiTermination --region ${REGION}
# aws ec2 modify-instance-attribute --instance-id ${INSTANCE_ID} --no-disable-api-termination --region ${REGION}
# aws iam create-login-profile --user-name ${IAM_USER} --password ${IAM_PW} --no-password-reset-required
# aws iam update-login-profile --user-name ${IAM_USER} --password ${IAM_PW} --no-password-reset-required
# aws ses verify-email-identity --email-address user@example.com
