resource "aws_iam_role" "private_ec2_role" {
  name = "petshop-private-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.private_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "private_ec2_secrets" {
  name = "petshop-private-ec2-secrets"
  role = aws_iam_role.private_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = "arn:aws:secretsmanager:us-east-1:226395400494:secret:petshop/prod/backend-PXxPkm"
      },
      {
        Effect = "Allow"

        Action = [
          "s3:*"
        ]

        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "private_ec2_profile" {
  name = "petshop-private-ec2-profile"
  role = aws_iam_role.private_ec2_role.name
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu official AWS account ID)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "private_ec2" {
  count = length(var.subnet_ids)

  ami = data.aws_ami.ubuntu.id

  instance_type = var.instance_type
  subnet_id     = var.subnet_ids[count.index]
  key_name      = var.key_name

  vpc_security_group_ids = [
    var.security_group_id
  ]

  iam_instance_profile = aws_iam_instance_profile.private_ec2_profile.name

  tags = { Name = var.ec2_name[count.index] }
}