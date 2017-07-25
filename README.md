# Sample demo environment for testing out GCP

## Usage
- Install Terraform (https://www.terraform.io/intro/getting-started/install.html)
- Create a new access key for Terraform to use. This page has a reference on how to create the access key (https://www.terraform.io/docs/providers/google/index.html)
- Put your new access key in the same directory as your Terraform template
- Update main.tf line 5 where MyFirstProject.json is the file name of your new key. 
- run 'terraform plan' from the same directory
- run 'terraform apply' (THIS WILL CREATE INSTANCES IN YOUR ENVIRONMENT)
