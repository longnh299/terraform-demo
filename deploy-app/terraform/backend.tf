terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "ap-southeast-1"
  }
}

terraform { #big block
    required_providers { #define cloud provider: aws, azure, gcp
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.11" # version of cloud provider
      }
    }

    #required_version = ">= 1.3.0" # version of tf
}
