provider "vsphere" {}

data "vsphere_datacenter" "dc" {
  name = var.dc
}

data "vsphere_datastore_cluster" "datastore_cluster" {
  count         = var.ds_cluster != "" ? 1 : 0
  name          = var.ds_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  count         = var.datastore != "" && var.ds_cluster == "" ? 1 : 0
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vm_rp
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vm_portgroup
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_tag_category" "category" {
  count = var.tags != null ? length(var.tags) : 0
  name  = keys(var.tags)[count.index]
}

data "vsphere_tag" "tag" {
  count       = var.tags != null ? length(var.tags) : 0
  name        = var.tags[keys(var.tags)[count.index]]
  category_id = "${data.vsphere_tag_category.category[count.index].id}"
}

variable "vm_specs" {
  type = map(object({
    vm_name              = string
    num_cpus             = string
    num_cores_per_socket = string
    memory               = string
    ip_addr              = string
    subnet_mask          = string
    gateway              = string
    additional_disks = map(object({
      label            = string
      size             = string
      unit_number      = string
      thin_provisioned = string
      eagerly_scrub    = string
      })
    ) }
  ))
}

locals {
  additional_disks = flatten([
    for vm_key, vm in var.vm_specs : [
      for additional_disk_key, additional_disk in vm.additional_disks : {
        vm_key               = vm_key
        additional_disks_key = additional_disks_key
        label                = additional_disk.label
        size                 = additional_disk.size
        unit_number          = additional_disk.unit_number
        thin_provisioned     = additional_disk.thin_provisioned
        eagerly_scrub        = additional_disk.eagerly_scrub
      }
    ]
  ])
}

resource "vsphere_virtual_machine" "windows" {
  for_each = var.is_windows_image == true ? var.vm_specs : {}

  name = each.value.vm_name

  resource_pool_id  = data.vsphere_resource_pool.pool.id
  folder            = var.vm_folder
  tags              = data.vsphere_tag.tag[*].id
  custom_attributes = var.custom_attributes
  annotation        = var.annotation
  extra_config      = var.extra_config

  datastore_cluster_id = var.ds_cluster != "" ? data.vsphere_datastore_cluster.datastore_cluster[0].id : null
  datastore_id         = var.datastore != "" ? data.vsphere_datastore.datastore[0].id : null

  num_cpus             = each.value.num_cpus
  num_cores_per_socket = each.value.num_cores_per_socket
  memory               = each.value.memory
  guest_id             = data.vsphere_virtual_machine.template.guest_id
  scsi_type            = data.vsphere_virtual_machine.template.scsi_type

  #wait_for_guest_net_routable = var.wait_for_guest_net_routable
  #wait_for_guest_ip_timeout   = var.wait_for_guest_ip_timeout
  #wait_for_guest_net_timeout  = var.wait_for_guest_net_timeout

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # Disks defined in the original template
  dynamic "disk" {
    for_each = data.vsphere_virtual_machine.template.disks
    iterator = template_disks

    content {
      label            = "disk-${template_disks.key}"
      size             = data.vsphere_virtual_machine.template.disks[template_disks.key].size
      unit_number      = template_disks.key
      thin_provisioned = data.vsphere_virtual_machine.template.disks[template_disks.key].thin_provisioned
      eagerly_scrub    = data.vsphere_virtual_machine.template.disks[template_disks.key].eagerly_scrub
    }
  }

  # Additional optional disks specified in vm_specs input variable map
  dynamic "disk" {
    for_each = {
      for additional_disk in local.additional_disks : "${additional_disk.vm_key}.${additional_disk.additional_disk_key}" => additional_disk
    }

    content {
      label            = each.value.label
      size             = each.value.size
      unit_number      = each.value.unit_number
      thin_provisioned = each.value.thin_provisioned
      eagerly_scrub    = each.value.eagerly_scrub
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    timeout       = var.clone_timeout

    customize {
      windows_options {
        computer_name         = each.value.vm_name
        admin_password        = var.local_adminpass
        join_domain           = var.join_domain
        domain_admin_user     = var.domain_admin_user
        domain_admin_password = var.domain_admin_password
        #organization_name     = var.orgname
        run_once_command_list = var.run_once
        auto_logon            = var.auto_logon
        auto_logon_count      = var.auto_logon_count
        time_zone             = var.time_zone
        #product_key           = var.productkey
        #full_name             = var.full_name
      }

      network_interface {
        ipv4_address = each.value.ip_addr
        ipv4_netmask = each.value.subnet_mask
      }

      dns_server_list = var.vm_dns
      dns_suffix_list = var.dns_suffix_list
      ipv4_gateway    = each.value.gateway
    }
  }
}
