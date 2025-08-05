# Azure Networking Requirements and Setup

## What This Code Creates
When Terraform runs, it will create the following key networking resources:
- Resource Group (contains all sub-resources)
    - Virtual Network
        - App Gateway Subnet
            - App Gateway
        - Azure Container Apps Subnet

## Network Reservation Requirements
For the DIBBs product to work, along with a reasonable cushion for modest scaling and futureproofing, we recommend **a minumum reservation of 256 IP addresses (/24) for the virtual network**. 

Your network allocation may vary according to the number of container nodes you plan to use in your jurisdiction. Resources and scaling are controlled by the Workload Profile within your Azuire Container Apps Environment.

We recommend a minimum reservation of **128 IP addresses (/25) for your Azure Container Apps Subnet**.

For reference, the relationship between subnet size, available IP addresses, and the corresponding maximum number of container nodes across all services and replicas is as follows:

| Subnet Size | Available IP Addresses* | Maximum Number of Container Nodes |
|-------------|------------------------|-----------------------------------|
| /23 | 500 | 250 |
| /24 | 244 | 122 |
| /25 | 116 | 58 |
| /26 | 52 | 26 |
| /27 | 20 | 10 |

*Subnet size minus the 12 IP addresses reserved by Azure for the Azure Container Apps infrastructure.

## Corresponding Terraform Configuration
User-configurable variables exist under the `"networking"` module in `terraform/dev/main.tf`. Your team should verify that their values are correct for your environment.

Make sure to verify the values for the following:
* `network_address_space` - The CIDR block for the full virtual network. Should be large enough to contain the two daughter subnets listed below.
* `aca_subnet_address_prefixes` - The CIDR block for the Azure Container Apps subnet. Should fall within the range of `network_address_space` to prevent errors on deploy. Should not conflict with the App Gateway subnet.
* `app_gateway_address_prefixes` - The CIDR block for the App Gateway subnet. Should fall within the range of `network_address_space` to prevent errors on deploy. Should not conflict with the Azure Container Apps subnet.

## Future Considerations
We strongly recommend reserving a small block of IP addresses in your `network_address_space` for future expansion. The default settings reserve a /26 block for the addition of future resources, including database servers or other future DIBBs products. You may choose to forego this recommendation if you are certain that you will not need additional resources in the future, or if you wish to use your own database servers.