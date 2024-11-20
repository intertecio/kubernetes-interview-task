variable "execute_kubernetes_manifests" {
  type    = bool
  default = false
}

variable "execute_helm_releases" {
  type    = bool
  default = false
}

variable "vpc" {
  type = any # used `any` for the sake of time :)
  default = {
    region               = "eu-central-1"
    account_id           = "402022866377"
    vpc_cidr             = "10.10.0.0/16"
    public_subnets_cidr  = ["10.10.110.0/24", "10.10.120.0/24", "10.10.130.0/24"]
    private_subnets_cidr = ["10.10.10.0/24", "10.10.20.0/24", "10.10.30.0/24"]
    availability_zones   = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  }
}

variable "ecr" {
  type = any # used `any` for the sake of time :)
  default = {
    repos = [
      {
        name                 = "node-demo-app"
        image_tag_mutability = "MUTABLE"
        encryption_configuration = {
          encryption_type = "AES256"
        }
        image_scanning_configuration = {
          scan_on_push = false
        }
      }
    ]
  }
}

variable "eks" {
  type = any # used `any` for the sake of time :)
  default = {
    cluster = {
      name    = "blue-green-demo"
      version = "1.31"
      vpc_config = {
        endpoint_private_access = "true"
        endpoint_public_access  = "true"
        public_access_cidrs     = ["185.25.195.104/32"]
      }
      enabled_cluster_log_types = []
      access_config = {
        authentication_mode                         = "API_AND_CONFIG_MAP"
        bootstrap_cluster_creator_admin_permissions = "true"
      }
      kubernetes_network_config = {
        service_ipv4_cidr = "192.168.128.0/20"
        ip_family         = "ipv4"
      }
    }
    node_group = {
      custom_id      = "node_group"
      name           = "node_group"
      ami_type       = "AL2023_ARM_64_STANDARD"
      ami_type_ssm   = "amazon-linux-2023/x86_64/standard"
      capacity_type  = "ON_DEMAND"
      disk_size      = "20"
      instance_types = ["t4g.small"]
      scaling_config = {
        desired_size = 3
        min_size     = 2
        max_size     = 4
      }
      update_config = {
        max_unavailable = 1
      }
    }
  }
}

variable "tags" {
  type = map(string)
  default = {
    Application = "blue-green-demo"
    Purpose     = "kubernetesInterviewTask"
    Maintainer  = "stamenchoBogdanovski"
  }
}