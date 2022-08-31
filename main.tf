
// Create resource group
resource "azurerm_resource_group" "IAC" {
  name     = "RG-IAC"
  location = "usgovvirginia"
}

resource "azurerm_virtual_network" "IAC" {
  name                = "IAC-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.IAC.location
  resource_group_name = azurerm_resource_group.IAC.name
}

resource "azurerm_subnet" "IAC" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.IAC.name
  virtual_network_name = azurerm_virtual_network.IAC.name
  address_prefixes     = ["10.0.2.0/24"]
}


# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.IAC.location
  resource_group_name = azurerm_resource_group.IAC.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "IAC" {
  name                = "IAC-nic"
  location            = azurerm_resource_group.IAC.location
  resource_group_name = azurerm_resource_group.IAC.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.IAC.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }
}

resource "azurerm_linux_virtual_machine" "IAC" {
  name                = "IAC-machine"
  resource_group_name = azurerm_resource_group.IAC.name
  location            = azurerm_resource_group.IAC.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.IAC.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  tags = {
    Name         = "IAC01"
    POC          = "Chet Camlin"
    Environment  = "IAC"
    CreateMethod = "Terraform"
    OS           = "RedHat 8.6"
    Owner        = "Chet Camlin"
    Reason       = "IAC Server"
    Email        = "chester.camlin.ctr@socom.mil"
    Phone        = "813-716-4552 or 813-826-6670"
  }

}