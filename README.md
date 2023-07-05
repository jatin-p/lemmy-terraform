# lemmy-terraform
 
# Terraform Project - Cloud Provisioning and Ansible setup

This Terraform project allows you to provision a single virtual machine (VM) in AWS, Azure, generate an SSH key pair, and then run an Ansible script on the provisioned VM.

## Prerequisites

Before you begin, ensure that you have the following prerequisites installed:

- Terraform: [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- AWS CLI [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Azure CLI: [Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Ansible: [Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/index.html)

 Terraform, AWS and Azure CLI were installed via following commands:
```bash
 winget install Amazon.AWSCLI
 winget install Microsoft.AzureCLI
 winget install Hashicorp.Terraform
```
Log into AWS and setup a "terraform" profile following the [guide here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

Log into Azure by following the [guide here](https://learn.microsoft.com/en-us/cli/azure/get-started-with-azure-cli)

Ansible was installed in WSL2 (Ubuntu 22.04 LTS)  via python-pip and the SSH keys generated to ```C:\Users\YourUsername\.ssh\examplekey``` and copied to ~/.ssh/ in WSL2 in order to log into Azure instance and follow [lemmy-ansible](https://github.com/LemmyNet/lemmy-ansible) repo to install lemmy

***AWS folder generates and saves SSH key "demokeypair.pem" file into the AWS directory***
***Azure folder assumes you generated ssh in following [section below](# Generate SSH keypair in Windows) and saved to "C:\Users\YourUsername\.ssh\lemmyazurekey"***
 
 ## Project Structure

The project directory structure is as follows:

```
.
├── main.tf
├── variables.tf
├── output.tf
├── providers.tf
```

- `main.tf`: Defines the cloud resource provisioning configuration.
- `variables.tf`: Contains input variables for the project.
- `outputs.tf`: Outputs public IP address and resource group name.
- `providers.tf`: Specifies the providers used in this project.

AWS folder allows you to create a Ubuntu 22.04 server using the free tier "t2.micro" (1vCPU, 1GB RAM) size virtual machine and also generates a "demokeypair.pem" file to log into VM via SSH. You must subscribe to Canoncials terms & conditions in AWS marketplace in order to provision a VM. Default region is AWS is ```us-east-2```

Azure folder creates a "Standard_B1s" (1vCPU, 1GB RAM) VM which is part of their free tier in region ```northcentralus```
## Usage

Follow these steps to generate the SSH key pair, provision the Azure VM, and run the Ansible script:

### Generate SSH keypair in Windows
1. Open the PowerShell terminal on your Windows machine.

2. Use the ssh-keygen command to generate the SSH key pair. Enter the following command:
```bash
ssh-keygen -t rsa -b 4096
```
3. Specify the file name and path to save the key pair. For example:
```bash
C:\Users\YourUsername\.ssh\examplekey
```
4.You will be prompted to enter a passphrase. You can either choose to enter a passphrase or leave it blank for an unprotected key.
5.  Key pair will generate a public key and private key
```bash
Your identification has been saved in C:\Users\YourUsername\.ssh\examplekey.
Your public key has been saved in C:\Users\YourUsername\.ssh\examplekey.pub.
```

### Provision infrastructure using Terraform

1. Clone this repository: `git clone https://github.com/jatin-p/lemmy-terraform.git`
2. Navigate to the desired project directory: `cd lemmy-terraform/azure`
3. Initialize Terraform: `terraform init`
4. Modify the `variables.tf` file to customize the project settings (i.e. location, vm_size) as needed.
5. Review and verify the configuration with `terraform plan`.
6. Provision the cloud VM: `terraform apply`
7. You shoud  see the Public IP (e.g. 1.2.3.4) and resourse group name (e.g. rg-gold-husky) output in terminal [for azure, AWS will output s3_bucketname, public_ip, etc.]


### Install Ansible and  lemmy
[Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible)
1.  Copy your SSH keys (Both .pub and private w/ no file extension) from ```~/.ssh``` to the WSL2 VM, ```\\wsl.localhost\Ubuntu-22.04\home\user\.ssh```
2.  SSH into your AWS/Azure VM via this command using the Public IP address output (replacing "1.2.3.4) in the previous section and copying your ssh key to ~/.ssh/ if using AWS:
``` bash
ssh -i  ~/.ssh/examplekey azureuser@1.2.3.4
```
4. Follow steps in the [lemmy-ansible](https://github.com/LemmyNet/lemmy-ansible) repo to install  lemmy

### lemmy-ansible configuration tips
- To use your ssh key in your ansible playbook (lemmy.yml), add the following line to the top of your playbook file between "gather_facts:" & "pre_tasks"
```bash
  vars:
    ansible_ssh_private_key_file: ~/.ssh/examplekey
    #rest of config options
```
- Modify the hosts file after copying from "inventory/hosts" to use your VM's public IP address or domain (after you create a DNS 'A' record pointing to your instance)
```bash
azureuser@<1.2.3.4 or lemmy.pictures>  domain=lemmy.pictures  letsencrypt_contact_email= example@email.com
```
- customPostgresql.conf is by default assuming your VM has higher specs than the free tier specs so use below to replace the settings in order opimize performance
```bash
# DB Version: 15
# OS Type: linux
# DB Type: web
# Total Memory (RAM): 1 GB
# CPUs num: 1
# Data Storage: ssd

max_connections = 200
shared_buffers = 256MB
effective_cache_size = 768MB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 7864kB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 655kB
min_wal_size = 1GB
max_wal_size = 4GB
```
## Clean Up

To clean up and remove the provisioned cloud resources, run the following command:

```bash
terraform destroy
```

Confirm the destruction when prompted.

**Note:** This action will permanently delete all resources provisioned/managed by this project. 
***THERE IS NO UNDO***

## Contributions

Contributions to this Terraform project are welcome. If you find any issues or have suggestions for improvement, please submit an issue or create a pull request.

## License

This project is licensed under the [GNU GPL v3 License]([LICENSE](https://github.com/jatin-p/lemmy-terraform/blob/main/LICENSE)).
