# task 1 Create a new Terraform project in a directory of your choice.
#2. Write the code to provision a GKE cluster in a single zone with three nodes, each with at least 2 vCPUs and 7.5 GB of memory.
provider "google" {
    project = "charged-atlas-234911"
    region = "us-central1"
    zone = "us-central1-a" 
}
#terraform state saved in storage bucket, multi region
terraform {
  backend "gcs" {
    bucket = "vrg-test-bld"
    prefix = "terraform/state"
    
    
  }
}