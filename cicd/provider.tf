terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "6.7.0"

        }
    }

    backend "s3" {
        bucket = "rev78s-remote-state"
        key    = "jenkins"
        region = "us-east-1"
        dynamodb_table = "daws78s-locking"
    }
}

provider "aws" {
    region = "us-east-1"
}