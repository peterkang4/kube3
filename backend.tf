terraform {
    backend "s3" {
        bucket = "peter-eks-terraform"
        key    = "eks-kube3"
        # bucket = var.BACKEND_BUCKET
        # key    = var.BUCKET_KEY
    }
}