terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://172.30.60.168:8006/api2/json"
  pm_api_token_id = "terraform-prov@pve!mytoken"
  pm_api_token_secret = "85ddc852-d23f-4bde-a59d-7ab1bf964467"
  pm_tls_insecure = true
  pm_debug = true
}

resource "proxmox_vm_qemu" "my_vm" {
  count       = 1
  name        = "my-vm"
  target_node = "pve"
  clone       = "my-cloud-init-template"
  disk {
  	type    = "scsi"
 	  storage = "local-lvm"
  	size    = "35G"
  }
  memory     = 2048
  cores      = 2
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  ipconfig0 = "ip=172.30.60.171/24,gw=172.30.60.1"
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
  # Once the creation of the VM is done, this block gets executed and tries to connect to the VM
  # Only if this attempted connection works, the Ansible part will start
  connection {
    host = "172.30.60.171"
    user = "notroot"
    # password = "x-net"
    private_key = file("/builds/root/automated-testing/.ssh/id_rsa")
    agent = false
    timeout = "15m"
  }

  # This command is executed on the VM.
  provisioner "remote-exec" {
    inline = [ "echo '!!! Terraform part completed. Now it is Ansibles turn. !!!' > terraform_done.txt" ]
  }

  # This command is executed on the local machine.
  # ANSIBLE KICK OFF
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command = "ansible-playbook ./playbooks/provision.yml --user notroot --private-key /builds/root/automated-testing/.ssh/id_rsa --extra-vars 'ansible_become_pass=x-net' -i ./inventory/hosts && ansible-playbook ./playbooks/unit_test.yml --user notroot --private-key /builds/root/automated-testing/.ssh/id_rsa --extra-vars 'ansible_become_pass=x-net' -i ./inventory/hosts"
  }
}