# Current account
data "aws_caller_identity" "current" {}

# Current AWS region
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.id
  region     = data.aws_region.current.name
  tags       = merge(var.tags, { resource = "EKS" })

  # Custom ENI
  subnets = {
    subnets = [
    for index, id in var.vpc.pods_subnet_ids : {
      subnet_id          = id
      az_name            = element(data.aws_availability_zones.available.names, index)
      security_group_ids = [module.eks.worker_security_group_id]
    }
    ]
  }

  # EKS worker groups
  eks_worker_group = concat([
  for index in range(0, length(var.eks_worker_groups)) :
  merge(var.eks_worker_groups[index], {
    "spot_allocation_strategy" = "capacity-optimized"
    "root_encrypted"           = true
    "root_kms_key_id"          = var.eks.encryption_keys.ebs_kms_key_id
    additional_userdata        = <<-EOT
      sudo yum update -y
      sudo amazon-linux-extras install -y epel
      sudo yum install -y s3fs-fuse
      sudo mkdir -p ${var.s3_fs.host_path}
      sudo s3fs ${var.s3_fs.name} ${var.s3_fs.host_path} -o iam_role="auto" -o use_path_request_style -o url="https://s3-${local.region}.amazonaws.com"
    EOT
    "tags"                     = [
      {
        key                 = "k8s.io/cluster-autoscaler/enabled"
        propagate_at_launch = true
        value               = true
      },
      {
        key                 = "k8s.io/cluster-autoscaler/${var.name}"
        propagate_at_launch = true
        value               = true
      },
      {
        key                 = "aws-node-termination-handler/managed"
        value               = true
        propagate_at_launch = true
      },
      {
        key                 = "lifecycle=OnDemand"
        value               = true
        propagate_at_launch = true
      }
    ]
  })
  ], [
    {
      name                                     = "operational-worker-ondemand"
      override_instance_types                  = ["m5.xlarge", "m5d.xlarge"]
      spot_instance_pools                      = 0
      asg_min_size                             = 1
      asg_max_size                             = 5
      asg_desired_capacity                     = 1
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 100
      spot_allocation_strategy                 = "capacity-optimized"
      kubelet_extra_args                       = "--node-labels=grid/type=Operator --register-with-taints=grid/type=Operator:NoSchedule"
      root_encrypted                           = true
      root_kms_key_id                          = var.eks.encryption_keys.ebs_kms_key_id
      additional_userdata                      = <<-EOT
        sudo yum update -y
        sudo amazon-linux-extras install -y epel
        sudo yum install -y s3fs-fuse
        sudo mkdir -p ${var.s3_fs.host_path}
        sudo s3fs ${var.s3_fs.name} ${var.s3_fs.host_path} -o iam_role="auto" -o use_path_request_style -o url="https://s3-${local.region}.amazonaws.com"
      EOT
    }
  ])
}