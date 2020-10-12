output "resource_groups" {
  value = azurerm_resource_group.test.*.name
}

output "cluster_names" {
  value = azurerm_resource_group.test.*.name
}

output "kubeconfigs" {
  value = [for rg in azurerm_resource_group.test : format("$HOME/.kube/%s", rg.name)]
}