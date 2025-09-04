### creating Jenkins-Master Instance ###
module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-master"

  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-023ff420fac1e729a"] #replace your SG
  subnet_id = "subnet-0cd5b9a7016bd1324" #replace your Subnet
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins.sh")
  create_security_group = false
  tags = {
    Name = "jenkins-master"
  }
}

### creating Jenkins-Agent Instance ###
module "jenkins_agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-agent"

  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-023ff420fac1e729a"]
  subnet_id = "subnet-0cd5b9a7016bd1324"
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins-agent.sh")
  create_security_group = false
  tags = {
    Name = "jenkins-agent"
  }
}

### creating Nexus Instance ###
## importing public key ##
resource "aws_key_pair" "tools" {
  key_name = "tools"
  public_key = file("~/.ssh/tools.pub")
}

module "nexus" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "nexus"

  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-023ff420fac1e729a"]
  subnet_id = "subnet-0cd5b9a7016bd1324"
  ami = data.aws_ami.ami_info.id
  create_security_group = false
  key_name = aws_key_pair.tools.key_name
  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 30
    }
  ]
  tags = {
    Name = "nexus"
  }
}

### creating r53 records master & agent ###
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 3.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins" 
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    },
     {
      name    = "jenkins-agent" 
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins_agent.private_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "nexus" 
      type    = "A"
      ttl     = 1
      records = [
        module.nexus.private_ip
      ]
      allow_overwrite = true
    }

  ]

}