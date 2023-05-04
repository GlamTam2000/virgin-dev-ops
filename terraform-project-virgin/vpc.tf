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