# Update Kubeconfig
resource "null_resource" "update_kubeconfig" {
  triggers   = {
    cluster_arn = module.eks.cluster_arn
  }
  provisioner "local-exec" {
    command = "sed -i 's/: null/: []/g' ~/.kube/config && aws eks update-kubeconfig --region ${var.eks.region} --name ${var.eks.cluster_name}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl config delete-cluster ${self.triggers.cluster_arn}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl config delete-context ${self.triggers.cluster_arn}"
  }
  depends_on = [
    module.eks
  ]
}