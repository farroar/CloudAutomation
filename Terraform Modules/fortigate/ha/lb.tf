#####################################################################
########################### Outside Load Balancer ###################
/*
resource "azurerm_lb" "outside_lb" {
  name                = "outside-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.fgt_rg.name

  frontend_ip_configuration {
    name                 = "FGT-cluster-public-PIP"
    public_ip_address_id = azurerm_public_ip.fgt_cluster_ip.id
  }
}

resource "azurerm_lb_probe" "outside_lb_probe" {
  resource_group_name = azurerm_resource_group.fgt_rg.name
  loadbalancer_id     = azurerm_lb.outside_lb.id
  name                = "lbprobe"
  port                = 8008
}

resource "azurerm_lb_backend_address_pool" "outside_lb_backend_pool" {
  resource_group_name = azurerm_resource_group.fgt_rg.name
  loadbalancer_id     = azurerm_lb.outside_lb.id
  name                = "outside-lb-backend-pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "fgta_outside_lb_association" {
  network_interface_id    = azurerm_network_interface.fgta_outside_nic.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.outside_lb_backend_pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "fgtb_outside_lb_association" {
  network_interface_id    = azurerm_network_interface.fgtb_outside_nic.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.outside_lb_backend_pool.id
}

resource "azurerm_lb_rule" "outside_lb_rule" {
  resource_group_name            = azurerm_resource_group.fgt_rg.name
  loadbalancer_id                = azurerm_lb.outside_lb.id
  name                           = "443-LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "FGT-cluster-public-PIP"
  probe_id                       = "lbprobe"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.outside_lb_backend_pool.id
  enable_floating_ip             =  true
}

resource "azurerm_lb_rule" "outside_lb_rule" {
  resource_group_name            = azurerm_resource_group.fgt_rg.name
  loadbalancer_id                = azurerm_lb.outside_lb.id
  name                           = "8443-LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 8443
  backend_port                   = 8443
  frontend_ip_configuration_name = "FGT-cluster-public-PIP"
  probe_id                       = "lbprobe"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.outside_lb_backend_pool.id
  enable_floating_ip             =  true
}

resource "azurerm_lb_rule" "outside_lb_rule" {
  resource_group_name            = azurerm_resource_group.fgt_rg.name
  loadbalancer_id                = azurerm_lb.outside_lb.id
  name                           = "22-LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "FGT-cluster-public-PIP"
  probe_id                       = "lbprobe"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.outside_lb_backend_pool.id
  enable_floating_ip             =  true
}

resource "azurerm_lb_rule" "outside_lb_rule" {
  resource_group_name            = azurerm_resource_group.fgt_rg.name
  loadbalancer_id                = azurerm_lb.outside_lb.id
  name                           = "UDP500-LBRule"
  protocol                       = "Udp"
  frontend_port                  = 500
  backend_port                   = 500
  frontend_ip_configuration_name = "FGT-cluster-public-PIP"
  probe_id                       = "lbprobe"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.outside_lb_backend_pool.id
  enable_floating_ip             =  true
}

resource "azurerm_lb_rule" "outside_lb_rule" {
  resource_group_name            = azurerm_resource_group.fgt_rg.name
  loadbalancer_id                = azurerm_lb.outside_lb.id
  name                           = "UDP4500-LBRule"
  protocol                       = "Udp"
  frontend_port                  = 4500
  backend_port                   = 4500
  frontend_ip_configuration_name = "FGT-cluster-public-PIP"
  probe_id                       = "lbprobe"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.outside_lb_backend_pool.id
  enable_floating_ip             =  true
}


#####################################################################
########################### Inside Load Balancer ####################


resource "azurerm_lb" "inside_lb" {
  name                = "outside-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.fgt_rg.name

  frontend_ip_configuration {
    name                          = "FGT-inside-transit-private-IP"
    subnet_id                     = module.vnet.vnet_subnets[1]
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.inside_subnet, 6)
  }
}

resource "azurerm_lb_probe" "inside_lb_probe" {
  resource_group_name = azurerm_resource_group.fgt_rg.name
  loadbalancer_id     = azurerm_lb.inside_lb.id
  name                = "lbprobe"
  port                = 8008
}

resource "azurerm_lb_backend_address_pool" "inside_lb_backend_pool" {
  resource_group_name = azurerm_resource_group.fgt_rg.name
  loadbalancer_id     = azurerm_lb.inside_lb.id
  name                = "inside-lb-backend-pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "fgta_inside_lb_association" {
  network_interface_id    = azurerm_network_interface.fgta_inside_nic.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.inside_lb_backend_pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "fgtb_inside_lb_association" {
  network_interface_id    = azurerm_network_interface.fgtb_inside_nic.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.inside_lb_backend_pool.id
}

resource "azurerm_lb_rule" "inside_lb_rule" {
  resource_group_name            = azurerm_resource_group.fgt_rg.name
  loadbalancer_id                = azurerm_lb.inside_lb.id
  name                           = "LBRule"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "FGT-inside-transit-private-IP"
  probe_id                       = "lbprobe"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.inside_lb_backend_pool.id
  enable_floating_ip             =  true
}
*/