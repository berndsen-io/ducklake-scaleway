variable "s3_bucket_name" {
  description = "Name for the Scaleway Object Storage bucket (must be globally unique)"
  type        = string
}

resource "scaleway_object_bucket" "ducklake" {
  name   = var.s3_bucket_name
  region = var.region

  versioning {
    enabled = false
  }

  tags = {
    project    = "ducklake"
    managed_by = "terraform"
  }
}

resource "scaleway_object_bucket_acl" "ducklake" {
  bucket = scaleway_object_bucket.ducklake.name
  region = var.region
  acl    = "private"
}
