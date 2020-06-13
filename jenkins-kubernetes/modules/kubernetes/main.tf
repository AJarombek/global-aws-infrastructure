
data "aws_eks_cluster" "andrew-jarombek-cluster" {
  name = "andrew-jarombek-eks-cluster"
}

provider "kubernetes" {
  host = data.aws_eks_cluster.andrew-jarombek-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.andrew-jarombek-cluster.certificate_authority.0.data)
}