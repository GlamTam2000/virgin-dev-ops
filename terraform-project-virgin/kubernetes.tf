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

  
  