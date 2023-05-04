#this will be used with NAT to allow kubernetes to pull docker images from internet 
resource "google_compute_router" "router" {
  name = "router"
  region = "us-central1"
  network = google_compute_network.main.id #vpc

}