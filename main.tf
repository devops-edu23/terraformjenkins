
# Create a VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = "false"
}

# Create a Subnet within the VPC Network
resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc_network.self_link
}

# Create a Router and associate it with the Subnet
resource "google_compute_router" "router" {
  name    = "my-router"
  network = google_compute_network.vpc_network.self_link
}


# Create a Security Group
resource "google_compute_firewall" "firewall" {
  name    = "my-security-group"
  network = google_compute_network.vpc_network.self_link
  priority = 199

  #allow {
   # protocol = "all"
   # ports    = ["all"]
   #} 

allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["all-instances"]
}

# Create an Ubuntu Instance
resource "google_compute_instance" "ubuntu_instance" {
  name         = "my-ubuntu-instance"
  machine_type = "e2-medium"
  #zone         = "<your-zone>"
  tags = ["http-server"]
boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link
    access_config {}
  }
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo 'Hello, World!' | sudo tee /var/www/html/index.html
  EOF
}
