# Provider task 1 Create a new Terraform project in a directory of your choice.
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
#vpc
#Enable API's for compute and container
resource "google_project_service" "compute" {
    service = "compute.googleapis.com"
  
}

resource "google_project_service" "container"{
    service = "container.googleapis.com"
}

#VPC
resource "google_compute_network" "main-network"{
    name = "main-network"
    routing_mode =  "REGIONAL"
    auto_create_subnetworks = false
    mtu = 1460  #maximum transition unit
}
depends_on = [ 
    google_project_service.compute,
    google_project_service.container
]
tags =  [ "vpc", "Apps"]
zone = us-central1

#subnets
resource "google_compute_subnetwork" "private" {
name = "private"
ip_cidr_range =  "10.0.0.0/18" #16000 ip's
region = "us-central1"
network = google_compute_network.main-network.id
private_ip_google_access = true #vm's/databases in this subnetwork without external IP can access google API's and services

# kubernetes nodes will use IP's from CIDR range. Pods will use the secondary ip range
secondary_ip_range = {
    range_name = "k8's-pod-range"
    ip_cidr_range = "10.48.0.0/14"
}
}
#router
#this will be used with NAT to allow kubernetes to pull docker images from internet 
resource "google_compute_router" "router" {
  name = "router"
  region = "us-central1"
  network = google_compute_network.main.id #vpc

}
#nat
resource "google_compute_router_nat" "nat"{
    name = "nat"
    router = google_compute_router.vrg-router.name
    region = "us-central1"

    source_subnetwork_ip_ranges_to_nat =  "LIST_OF_SUBNETWORKS" 
    nat_ip_allocate_option = "MANUAL_ONLY"

    subnetwork {
      name = google_compute_subnetwork.private.id
      source_ip_ranges_to_nat =  ["ALL_IP_RANGES"]
    }

    nat_ips =  [google_compute_address.nat.self_link ]

}

resource "google_compute_address" "nat" {
    name = "nat"
    address_type = "INTERNAL"
    network_tier = "STANDARD"
  
}
#Kubernetes cluster
resource "google_service_account" "App-Team" {
  account_id   = "App-Team"
}

resource "google_project_iam_member" "App-Team" {
  project = "charged-atlas-234911"
  role = "roles/serviceaccount.user"
  member = "serviceAccount:app-team-740@charged-atlas-234911.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "App-Team"{
    servservice_account_id = google_service_account.App-Team.id
    role = "roles/iam.workloadIdentityUser"
    member = "serviceAccount:app-team-740@charged-atlas-234911.iam.gserviceaccount.com"

}
    
resource "google_container_cluster" "vrg-primary" {
  name     = "vrg-primary"
  location = "us-central1"
  remove_default_node_pool = true
  node_count = 3
  
  node_config {
    preemptible  = true
    machine_type = "e2-medium"
   labels = {
   role = "web-app"
  network =  google_compute_network.main.self_link
  subnetwork = google_compute_subnetwork.private.self_link
 }
 
  #logging_service = "logging.googleapis.com/kubernetes" # Need to enable API
  #monitoring_service = "monitoring.googleapis.com/kubernetes" # Need to enable API
  networking_mode = "VPC_NATIVE"
  cluster    = google_container_cluster.vrg-primary.name
}
}

  
  