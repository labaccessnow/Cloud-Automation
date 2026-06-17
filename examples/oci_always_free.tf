# Oracle Cloud "Always Free" Arm (Ampere A1.Flex) instance — the workhorse of a
# zero-cost cloud footprint. Free within the A1 allocation, but mind the cap: Oracle
# has tightened the free A1 limit account-wide, and over-cap instances get reclaimed.
terraform {
  required_providers {
    oci = { source = "oracle/oci", version = "~> 6.0" }
  }
}

provider "oci" {}   # auth from ~/.oci/config or OCI_CLI_* env vars — never hardcode keys

variable "compartment_ocid" { type = string }
variable "subnet_ocid"      { type = string }
variable "image_ocid"       { type = string } # an Ubuntu / Oracle-Linux ARM image OCID

variable "ssh_public_key" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

resource "oci_core_instance" "free_arm" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "free-arm-01"
  shape               = "VM.Standard.A1.Flex" # Ampere ARM — Always Free eligible

  shape_config {
    ocpus         = 2   # keep total A1 usage within your account's free allocation
    memory_in_gbs = 12
  }

  source_details {
    source_type = "image"
    source_id   = var.image_ocid
  }

  create_vnic_details {
    subnet_id        = var.subnet_ocid
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key)
  }
}

output "public_ip" { value = oci_core_instance.free_arm.public_ip }
