data "azurerm_subnet" "subnet" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${var.virtual_network_name}"
  resource_group_name  = "${var.resource_group_name}"
}

resource "azurerm_subnet_route_table_association" "rt" {
  subnet_id      = "${data.azurerm_subnet.subnet.id}"
  route_table_id = "${var.route_table_id}"
}
