terraform {
    backend "s3" {
        bucket = "peter-eks-terraform"
        key    = "eks-kubernetes2"
    }
}