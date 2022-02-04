############################
# VARIABLES
############################

variable "region" {
    type = string
    default = "us-east-1"
}

variable "name" {
    type =string
    default = "PartsUnlimited"
}

variable "vpc_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "database_subnets" {
  type = list(string)
  default = ["10.0.8.0/24", "10.0.9.0/24"]
}

variable "dbpassword" {
    type = string
    default = "buRfuaoPLsAM2A7x4sGpGyxh7O"
}

variable "dbuser" {
    type = string
    default = "sqladmin"
}

############################
# PROVIDERS
############################

provider "aws" {
    region  = var.region
}

#############################################################################
# DATA SOURCES
#############################################################################

data "aws_availability_zones" "azs" {}

data "http" "my_ip" {
    url = "http://ifconfig.me"
}

data "aws_caller_identity" "current" {}

############################
# RESOURCES
############################

## VPC

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name = "${var.name}-vpc"
  cidr = var.vpc_cidr_range

  azs            = slice(data.aws_availability_zones.azs.names, 0, 2)
  public_subnets = var.public_subnets

  # Database subnets
  database_subnets  = var.database_subnets

}

## Security groups

# LB SG

resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "Allow traffic for ELB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow ALL"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow ALL"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Launch Config

resource "aws_security_group" "launch_config" {
  name        = "launch_config"
  description = "Allow traffic for launch config"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow ALL"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    description = "Allow ALL"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# RDS
resource "aws_db_instance" "default" {
  allocated_storage    = 200
  engine               = "sqlserver-se"
  instance_class       = "db.m5.xlarge"
  engine_version         = "15.00.4073.23.v1"
  #name                 = "PartsUnlimitedDB"
  username             = var.dbuser
  password             = var.dbpassword
  skip_final_snapshot  = true
  license_model          = "license-included"
  tags = {
    Project = "21.204"
  }
}



## Elastic Beanstalk

resource "aws_elastic_beanstalk_application" "PartsUnlimited" {
  name        = var.name
  description = "PartsUnlimited On Web Application"
}

resource "aws_elastic_beanstalk_environment" "PartsUnlimited" {
  name                = "${var.name}-env"
  application         = aws_elastic_beanstalk_application.PartsUnlimited.name
  solution_stack_name = "64bit Windows Server 2019 v2.8.1 running IIS 10.0"

    setting {
        resource = "AWSEBAutoScalingGroup"
        namespace = "aws:autoscaling:asg"
        name = "MaxSize"
        value = "4"
    }

    setting {
        resource = "AWSEBAutoScalingGroup"
        namespace = "aws:autoscaling:asg"
        name = "MinSize"
        value = "4"
    }

    setting {
        resource = "AWSEBAutoScalingLaunchConfiguration"
        namespace = "aws:autoscaling:launchconfiguration"
        name = "IamInstanceProfile"
        value = "aws-elasticbeanstalk-ec2-role"
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name = "InstanceType"
        value = "c5.large"
    }

    setting {
        resource = "AWSEBCloudwatchAlarmLow"
        namespace = "aws:autoscaling:trigger"
        name = "LowerThreshold"
        value = "25"
    }

    setting {
        resource = "AWSEBCloudwatchAlarmLow"
        namespace = "aws:autoscaling:trigger"
        name = "MeasureName"
        value = "CPUUtilization"
    }

    setting {
        resource = "AWSEBCloudwatchAlarmLow"
        namespace = "aws:autoscaling:trigger"
        name = "Unit"
        value = "Percent"
    }

    setting {
        resource = "AWSEBCloudwatchAlarmHigh"
        namespace = "aws:autoscaling:trigger"
        name = "UpperThreshold"
        value = "70"
    }

    setting {
        namespace = "aws:cloudformation:template:parameter"
        name = "InstanceTypeFamily"
        value = "c5"
    }

    setting {
        namespace = "aws:ec2:instances"
        name = "InstanceTypes"
        value = "c5.large"
    }

    setting {
        resource = "AWSEBAutoScalingLaunchConfiguration"
        namespace = "aws:ec2:vpc"
        name = "AssociatePublicIpAddress"
        value = "true"
    }

    setting {
        resource = "AWSEBRDSDBSubnetGroup"
        namespace = "aws:ec2:vpc"
        name = "DBSubnets"
        value = join(",",module.vpc.database_subnets)
    }

    setting {
        namespace = "aws:ec2:vpc"
        name = "ELBSubnets"
        value = join(",",module.vpc.public_subnets)
    }

    setting {
        resource = "AWSEBAutoScalingGroup"
        namespace = "aws:ec2:vpc"
        name = "Subnets"
        value = join(",",module.vpc.public_subnets)
    }

    setting {
        resource = "AWSEBLoadBalancerSecurityGroup"
        namespace = "aws:ec2:vpc"
        name = "VPCId"
        value = module.vpc.vpc_id
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment"
        name = "LoadBalancerType"
        value = "application"
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment"
        name = "ServiceRole"
        value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-elasticbeanstalk-service-role"
    }
    
    setting {
        resource = "AWSEBV2LoadBalancerTargetGroup"
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "StickinessEnabled"
        value = "false"
    }

    setting {
        resource = "AWSEBV2LoadBalancerTargetGroup"
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "StickinessEnabled"
        value = "false"
    }

    setting {
        resource = "AWSEBRDSDatabase"
        namespace = "aws:rds:dbinstance"
        name = "DBAllocatedStorage"
        value = "200"
    }

    setting {
        resource = "AWSEBRDSDatabase"
        namespace = "aws:rds:dbinstance"
        name = "DBDeletionPolicy"
        value = "Snapshot"
    }

    setting {
        resource = "AWSEBRDSDatabase"
        namespace = "aws:rds:dbinstance"
        name = "DBEngine"
        value = "sqlserver-se"
    }
    
    setting {
        resource = "AWSEBRDSDatabase"
        namespace = "aws:rds:dbinstance"
        name = "DBInstanceClass"
        value = "db.m5.xlarge"
    }

    setting {
        namespace = "aws:rds:dbinstance"
        name = "DBPassword"
        value = var.dbpassword
    }

    setting {
        namespace = "aws:rds:dbinstance"
        name = "DBUser"
        value = var.dbuser
    }

    setting {
        resource = "AWSEBRDSDatabase"
        namespace = "aws:rds:dbinstance"
        name = "MultiAZDatabase"
        value = "false"
    }

}

## RDS

############################
# OUTPUTS
############################

output "my_ip" {
    value = data.http.my_ip.body
}