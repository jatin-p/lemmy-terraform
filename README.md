# lemmy-terraform
 
# Terraform Project - Azure Provisioning and Ansible setup

This Terraform project allows you to provision a single virtual machine (VM) in Azure, generate an SSH key pair, and then run an Ansible script on the provisioned VM.

## Prerequisites

Before you begin, ensure that you have the following prerequisites installed:

- Terraform: [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Azure CLI: [Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Ansible: [Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/index.html)

 Terraform and Azure CLI were installed via following commands:
```bash
 winget install Microsoft.AzureCLI
 winget install Hashicorp.Terraform
```
 
Ansible was installed in WSL2 (Ubuntu 22.04 LTS)  via python pip and the SSH keys were copied from ~/.ssh/ to WSL2 in order to log into Azure instance and follow [lemmy-ansible](https://github.com/LemmyNet/lemmy-ansible) repo to install lemmy
 
 ## Project Structure

The project directory structure is as follows:

```
.
├── main.tf
├── variables.tf
├── output.tf
├── providers.tf
```

- `main.tf`: Defines the Azure resource provisioning configuration.
- `variables.tf`: Contains input variables for the project.
- `outputs.tf`: Outputs public IP address and resource group name.
- `providers.tf`: Specifies the providers used in this project.

## Usage

Follow these steps to generate the SSH key pair, provision the Azure VM, and run the Ansible script:

### Generate SSH keypair in Windows
1. Open the PowerShell terminal on your Windows machine.

2. Use the ssh-keygen command to generate the SSH key pair. Enter the following command:
```bash
ssh-keygen -t rsa -b 2048
```
3. Specify the file name and path to save the key pair. For example:
```bash
C:\Users\YourUsername\.ssh\lemmyazurekey
```
4.You will be prompted to enter a passphrase. You can either choose to enter a passphrase or leave it blank for an unprotected key.
5.  Key pair will generate a public key and private key
```bash
Your identification has been saved in C:\Users\YourUsername\.ssh\lemmyazurekey.
Your public key has been saved in C:\Users\YourUsername\.ssh\lemmyazurekey.pub.
```

### Provision infrastructure using Terraform

1. Clone this repository: `git clone https://github.com/jatin-p/lemmy-terraform.git`
2. Navigate to the project directory: `cd lemmy-terraform/azure`
3. Initialize Terraform: `terraform init`
4. Modify the `variables.tf` file to customize the project settings (i.e. location, vm_size) as needed.
5. Review and verify the configuration with `terraform plan`.
6. Provision the Azure VM: `terraform apply`
7. You shoud  see the Public IP (e.g. 1.2.3.4) and resourse group name (e.g. rg-gold-husky) output in terminal


### Install Ansible and  lemmy
[Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
1.  Copy your SSH keys (Both .pub and private w/ no file extension) from ```~/.ssh``` to the WSL2 VM, ```\\wsl.localhost\Ubuntu-22.04\home\user\.ssh```
2.  SSH into your Azure VM via this command using the Public IP address output in the previous section:
``` bash
ssh -i  ~/.ssh/lemmyazurekey azureuser@1.2.3.4
```
4. Follow steps in the [lemmy-ansible](https://github.com/LemmyNet/lemmy-ansible) repo

## Clean Up

To clean up and remove the provisioned Azure resources, run the following command:

```bash
terraform destroy
```

Confirm the destruction when prompted.

**Note:** This action will permanently delete all resources provisioned by this project. THERE IS  NO UNDO

## Contributions

Contributions to this Terraform project are welcome. If you find any issues or have suggestions for improvement, please submit an issue or create a pull request.

## License

This project is licensed under the [GNU GPL v3 License]([LICENSE](https://github.com/jatin-p/lemmy-terraform/blob/main/LICENSE)).
