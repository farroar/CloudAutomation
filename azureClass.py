#!/usr/bin/python3
'''
##############################################################################
This class defines a vnet in an object as well as methods to add and remove
attributes. This class doesn't do any adjustments in Azure. Only allows the
creation of an object.

Nathan Farrar - 17-Aug-2019
##############################################################################
'''

class vnet_object:

    def __init__(self, name, subscriptionId, location, resourceGroup, vnetPrefixes, orgName, lzType, bastionPrefix, azfwPrefix, gatewayPrefix, gatewayIP,securityCenter, stateStorageAccount=None, stateStorageFile=None):
        self.name = name
        self.subscriptionId = subscriptionId
        self.location = location
        self.resourceGroup = resourceGroup
        self.vnetPrefixes = vnetPrefixes
        self.orgName = orgName
        self.subnets = []
        self.peers = []
        self.testVM = []
        self.tags = {}
        self.lzType = lzType
        self.stateStorageAccount = stateStorageAccount
        self.stateStorageFile = stateStorageFile
        self.bastionPrefix = bastionPrefix
        self.azfwPrefix = azfwPrefix
        self.gatewayPrefix = gatewayPrefix
        self.gatewayIP = gatewayIP
        self.securityCenter = securityCenter

    def add_tags(self, data):
        split_tags = data.split(',')
        for i in split_tags:
            split_values = i.split(':')
            self.tags[split_values[0].lstrip()] = split_values[1].lstrip()
        return self.tags

    def delete_tag(self, tag):
        if tag in self.tags:
            del self.tags[tag]
        return self.tags

    def add_peer(self, peerName):
        self.peers.append(peerName)
        return self.peers

    def delete_peer(self, peer):
        self.peers = [i for i in self.peers if not (i['peerName'] == peer)]
        return self.peers

    def add_subnet(self, addressPrefix, name, nextHopType):
        self.subnets.append({
            'name': name,
            'addressPrefix': addressPrefix,
            'nextHopType': nextHopType
        })
        return self.subnets

    def delete_subnet(self, name):
        self.subnets = [i for i in self.subnets if not (i['name'] == name)]
        return self.subnets
    
    def add_prefix(self, prefix):
        self.vnetPrefixes.append(prefix)

    def delete_prefix(self, prefix):
        self.vnetPrefixes = [i for i in self.vnetPrefixes if not (i['prefix'] == prefix)]
        return self.vnetPrefixes

    def add_testVM(self, subnet):
        self.testVM.append(subnet)

    def delete_testVM(self, subnet):
        self.testVM = [i for i in self.testVM if not (i['testVM'] == subnet)]
        return self.testVM

def azure_peering(vnet):
    return

def azure_policy():
    return