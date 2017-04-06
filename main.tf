#######################################################
### Configure the Google Cloud provider - Initial setup
#######################################################
provider "google" {
  credentials = "${file("MyFirstProject.json")}"
  project     = "handy-zephyr-155200"
  region      = "us-central1"
}

#############
### Variables
#############
variable "machine_type" {
	default = "f1-micro"
}

##################
### Firewall rules
##################

resource "google_compute_firewall" "mongo" {
  name    = "mongo"
  network = "${google_compute_network.production.name}"
  target_tags = ["mongo"]
  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
  source_tags = ["mongo","webapp","arbiter","agents","scheduler","notification"]
}

resource "google_compute_firewall" "remote-desktop" {
  name    = "remote-desktop"
  network = "${google_compute_network.production.name}"
  target_tags = ["scheduler"]
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  source_ranges = ["10.10.9.0/24","10.11.88.0/24","10.100.68.11/32"]
 }

resource "google_compute_firewall" "problematic-rule" {
  name    = "problematic-rule"
  network = "${google_compute_network.production.name}"
  target_tags = ["backup"]
  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "notification443" {
  name    = "notification443"
  network = "${google_compute_network.production.name}"
  target_tags = ["notification"]
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "test-bastion" {
  name    = "test-bastion"
  network = "${google_compute_network.production.name}"
  target_tags = ["bastion"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "arbiter" {
  name    = "arbiter"
  network = "${google_compute_network.production.name}"
  target_tags = ["arbiter"]
  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }
  source_tags = ["mongo"]
}

resource "google_compute_firewall" "bastion-office" {
  name    = "bastion-office"
  network = "${google_compute_network.production.name}"
  target_tags = ["bastion"]
  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
  source_ranges = ["55.55.55.55"]
}

resource "google_compute_firewall" "elb-webapp" {
  name    = "elb-webapp"
  network = "${google_compute_network.production.name}"
  target_tags = ["webapp"]
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["104.199.74.254","99.215.154.9","104.199.74.20","104.198.8.41","99.215.155.0/24","39.51.111.4"]
}

resource "google_compute_firewall" "entire-network-rule" {
  name    = "entire-network-rule"
  network = "${google_compute_network.production.name}"
#  target_tags = ["Apply to all targets"]
  allow {
    protocol = "tcp"
    ports    = ["7777"]
  }
  source_ranges = ["10.1.2.3/32"]
}

###########
### Network
###########
resource "google_compute_network" "production" {
  name                    = "production"
  auto_create_subnetworks = "true"
}
resource "google_compute_network" "staging" {
  name                    = "staging"
  auto_create_subnetworks = "true"
}


###########
### Region specific things. Not re-setting up because we're on the Central region from the network settings.
###########



#############
### Instances
#############

resource "google_compute_instance" "agents1-us-central" {
  depends_on = ["google_compute_network.production"]
  name         = "agents1-us-central"
  machine_type = "${var.machine_type}"
  zone         = "us-central1-a"
  tags = ["agents", "prod"]
# metadata_startup_script = "echo hi > /test.txt"

  disk {
    image = "debian-cloud/debian-8"
  }

  network_interface {
    network = "production"
  }
}

resource "google_compute_instance" "bastion" {
  depends_on = ["google_compute_network.production"]
  name         = "bastion"
  machine_type = "${var.machine_type}"
  zone         = "us-central1-b"
  tags = ["bastion", "prod"]
# metadata_startup_script = "echo hi > /test.txt"

  disk {
    image = "debian-cloud/debian-8"
  }

  network_interface {
    network = "production"
  }
}

resource "google_compute_instance" "mongo-arbiter-us-west" {
  depends_on = ["google_compute_network.production"]
  name         = "mongo-arbiter-us-west"
  machine_type = "${var.machine_type}"
  zone         = "us-central1-c"
  tags = ["arbiter", "prod"]
# metadata_startup_script = "echo hi > /test.txt"

  disk {
    image = "debian-cloud/debian-8"
  }
  network_interface {
    network = "production"
  }
}

resource "google_compute_instance" "scheduler-us-central" {
  depends_on = ["google_compute_network.production"]
  name         = "scheduler-us-central"
  machine_type = "${var.machine_type}"
  zone         = "us-central1-c"
  tags = ["scheduler", "prod"]
# metadata_startup_script = "echo hi > /test.txt"

  disk {
    image = "debian-cloud/debian-8"
  }
  network_interface {
    network = "production"
  }
}

resource "google_compute_instance" "mongo-member-backup-eu-west" {
  depends_on = ["google_compute_network.production"]
  name         = "mongo-member-backup-eu-west"
  machine_type = "${var.machine_type}"
  zone         = "us-central1-a"
  tags = ["backup","mongo","prod"]
# metadata_startup_script = "echo hi > /test.txt"

  disk {
    image = "debian-cloud/debian-8"
  }

  network_interface {
    network = "production"
  }
}

resource "google_compute_instance" "notification-us-central" {
  depends_on = ["google_compute_network.production"]
  name         = "notification-us-central"
  machine_type = "${var.machine_type}"
  zone         = "us-central1-c"
  tags = ["notification", "prod"]
# metadata_startup_script = "echo hi > /test.txt"

  disk {
    image = "debian-cloud/debian-8"
  }
  network_interface {
    network = "production"
  }
}

resource "google_compute_instance" "webapp1-us-central1" {
  depends_on = ["google_compute_network.production"]
  name         = "webapp1-us-central1"
  machine_type = "${var.machine_type}"
  zone         = "us-central1-c"
  tags = ["webapp", "prod"]
# metadata_startup_script = "echo hi > /test.txt"

  disk {
    image = "debian-cloud/debian-8"
  }
  network_interface {
    network = "production"
  }
}

resource "google_compute_instance" "webapp1-us-central2" {
  depends_on = ["google_compute_network.production"]
  name         = "webapp1-us-central2"
  machine_type = "${var.machine_type}"
  zone         = "us-central1-c"
  tags = ["webapp", "prod"]
# metadata_startup_script = "echo hi > /test.txt"

  disk {
    image = "debian-cloud/debian-8"
  }
  network_interface {
    network = "production"
  }
}

#########################################
### Re-setup for West region instances
#########################################
provider "google_west" {
  credentials = "${file("MyFirstProject.json")}"
  project     = "handy-zephyr-155200"
  region      = "us-west1"
}

#############
### Instances
#############

resource "google_compute_instance" "agents1-us-west" {
  depends_on = ["google_compute_network.production"]
  name         = "agents1-us-west"
  machine_type = "${var.machine_type}"
  zone         = "us-west1-a"
  tags = ["agents", "prod"]
# metadata_startup_script = "echo hi > /test.txt"

  disk {
    image = "debian-cloud/debian-8"
  }

  network_interface {
    network = "production"
  }
}

resource "google_compute_instance" "mongo-member1-backup-us-west" {
  depends_on = ["google_compute_network.production"]
  name         = "mongo-member1-backup-us-west"
  machine_type = "${var.machine_type}"
  zone         = "us-west1-a"
  tags = ["backup", "mongo","prod"]
# metadata_startup_script = "echo hi > /test.txt"

  disk {
    image = "debian-cloud/debian-8"
  }

  network_interface {
    network = "production"
  }
}

resource "google_compute_instance" "mongo-member2-backup-us-west" {
  depends_on = ["google_compute_network.production"]
  name         = "mongo-member2-backup-us-west"
  machine_type = "${var.machine_type}"
  zone         = "us-west1-a"
  tags = ["mongo","prod"]
# metadata_startup_script = "echo hi > /test.txt"

  disk {
    image = "debian-cloud/debian-8"
  }

  network_interface {
    network = "production"
  }
}

resource "google_compute_instance" "stg-agents1-us-west" {
  depends_on = ["google_compute_network.staging"]
  name         = "stg-agents1-us-west"
  machine_type = "${var.machine_type}"
  zone         = "us-west1-a"
  tags = ["agents", "staging"]
# metadata_startup_script = "echo hi > /test.txt"

  disk {
    image = "debian-cloud/debian-8"
  }

  network_interface {
    network = "staging"
  }
}
