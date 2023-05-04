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