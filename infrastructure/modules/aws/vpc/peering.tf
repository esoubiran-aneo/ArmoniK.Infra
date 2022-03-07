resource "aws_vpc_peering_connection" "peering" {
  count         = (var.vpc.peering.enabled ? length(var.vpc.peering.peer_vpc_ids) : 0)
  peer_owner_id = data.aws_caller_identity.current.id
  peer_vpc_id   = var.vpc.peering.peering.peer_vpc_ids[count.index]
  vpc_id        = module.vpc.vpc_id
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  requester {
    allow_remote_vpc_dns_resolution = true
  }
  tags          = local.tags
  depends_on    = [module.vpc]
}