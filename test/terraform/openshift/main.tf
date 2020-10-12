provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "random_id" "suffix" {
  count       = var.cluster_count
  byte_length = 4
}

resource "azurerm_resource_group" "test" {
  count    = var.cluster_count
  name     = "consul-k8s-${random_id.suffix[count.index].dec}"
  location = var.region
}
resource "azurerm_virtual_network" "test" {
  count               = var.cluster_count
  name                = "consul-k8s-${random_id.suffix[count.index].dec}"
  location            = azurerm_resource_group.test[count.index].location
  resource_group_name = azurerm_resource_group.test[count.index].name
  address_space       = ["10.0.0.0/22"]
}

resource "azurerm_subnet" "master-subnet" {
  count                                         = var.cluster_count
  name                                          = "master-subnet"
  resource_group_name                           = azurerm_resource_group.test[count.index].name
  virtual_network_name                          = azurerm_virtual_network.test[count.index].name
  address_prefixes                              = ["10.0.0.0/23"]
  enforce_private_link_service_network_policies = true
  service_endpoints                             = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_subnet" "worker-subnet" {
  count                = var.cluster_count
  name                 = "worker-subnet"
  resource_group_name  = azurerm_resource_group.test[count.index].name
  virtual_network_name = azurerm_virtual_network.test[count.index].name
  address_prefixes     = ["10.0.2.0/23"]
  service_endpoints    = ["Microsoft.ContainerRegistry"]
}

resource "null_resource" "aro" {
  count = var.cluster_count

  triggers = {
    name          = azurerm_subnet.master-subnet[count.index].resource_group_name
    master_subnet = azurerm_subnet.master-subnet[count.index].id
    worker_subnet = azurerm_subnet.worker-subnet[count.index].id
  }

  # This is a horrible hack until terraform Azure provider officially supports this resource
  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/3614.
  provisioner "local-exec" {
    command = <<EOF
    az aro create \
      --resource-group ${azurerm_resource_group.test[count.index].name} \
      --name ${self.triggers.name} \
      --vnet ${azurerm_virtual_network.test[count.index].name} \
      --vnet-resource-group ${azurerm_resource_group.test[count.index].name} \
      --master-subnet master-subnet \
      --worker-subnet worker-subnet
    EOF
  }

  provisioner "local-exec" {
    command     = "./oc-login.sh ${self.triggers.name} ${self.triggers.name}"
    interpreter = ["/bin/bash", "-c"]
  }

  provisioner "local-exec" {
    when    = destroy
    command = "az aro delete --resource-group ${self.triggers.name} --name ${self.triggers.name} --yes"
  }
}