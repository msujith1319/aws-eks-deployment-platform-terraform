

# RSA key of size 4096 bits
//This creates the keypair( public and private keys) inside terraform
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Terraform takes that generated public key and uploads it to the  AWS 
resource "aws_key_pair" "bastion-key" {
  key_name   = "bastion-key"
  public_key = tls_private_key.key_pair.public_key_openssh
}


// Saving the private key to a local file, so that we can use it to connect to the bastion host later.
resource "local_file" "bastion-private-key" {
  content         = tls_private_key.key_pair.private_key_pem
  filename        = "bastion-key.pem"
  file_permission = "0400"
}



module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "bastion-host-sg"
  description = "bastion-host security group"
  vpc_id      = var.vpc_id

  ingress_rules = {
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = "${chomp(data.http.my_ip.response_body)}/32"
      description = "SSH from internal"
    }
    self-all = {
      ip_protocol                  = "-1"
      referenced_security_group_id = "self"
      description                  = "All traffic from members of this SG"
    }
  }

  egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = {
    Environment = "dev"
  }
}


module "bastion_host" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "bastion-instance"

  instance_type          = "t3.micro"
  key_name               = aws_key_pair.bastion-key.key_name
  ami                    = data.aws_ami.ubuntu.id
  monitoring             = true
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [module.security_group.id]

  associate_public_ip_address = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}