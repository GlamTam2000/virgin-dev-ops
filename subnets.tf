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