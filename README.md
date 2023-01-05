# Introduction
We're going to create an Nodejs application running under Azure Virtual Machine Scale Set with an Application gateway using Terraform.

# Prerequisites
- Terraform version 1.3.x

# Getting Started
## 1. Preparing Terraform parameter file
Let's create a Terraform parameter file like ```parameters.tfvars```
```
vnet_name = "hatr-vnet"
resource_group_name = "hatr-vmss"	 	
address_space = ["10.80.0.0/16"] 	 	
subnet_address_prefix = ["10.80.1.0/24"] 	 	
frontend_subnet_address_prefix  =  ["10.80.254.0/24"] 	

vmss_name = "hatr-api-vmss" 	 	
vmss_type = "linux" 	 	
instances  =  2 	 	
subnet_name = "hatr-api-vmss" 	 	
admin_username = "adminuser" 	 	
admin_password  =  "Ya222nrLTeCzTT" 	 	

nodejs_repo_url = "https://github.com/epiHATR/simple-express.git" 	 	
backend_port = "9000"
start_file  =  "index.js"	

enable_bastion  =  "true"
bastion_subnet_address_prefix  =  ["10.80.0.0/24"]
```

## 2. Setting Terraform environment variables for Azure authentication
Create An Azure service principal then export following information so Terraform can authenticates using Azure Resource Provider
```
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

## 3. Run Terraform Init & Plan
After cloning this repository to your local machine and have parameter file created along side with above environment variables exported, you can run Terraform Init to setup Terraform instance by
```
cd terraform
terraform init
```

then run Terraform plan to see resources to be created in Azure
```
cd terraform
terraform plan -var-file=parameters.tfvars
```

## 4. Run Terraform Apply
After confirm with the changes in the ```terraform plan```, you can choose apply current changes by 
```
cd terraform
terraform apply -var-file=parameters.tfvars
```

## 5. Verify resources & application
After ```terraform apply``` complted, you can see an output appears, that's the Public IP of the Azure Application Gateway which serves request and routes to the NodeJS applications deployed in the Azure Virtual Machine Scale Set.

See more article of Terraform at [Terraform Azure at https://cloudcli.io](https://cloudcli.io)