if code of instance is not same as state file then pull and update in state file
Terraform Migrate

terraform plan -generate-config-out=test.tf
terraform import aws_instance.example-1 instance_id

Terraform workspace

terraform workspace new workspacename
terraform workspace select workspace
terraform apply -var-file=stage.tfvars 

terraform workspace delete -force -lock=false prod

to unlock locked mechanism of state file
terraform destroy -var-file=dev.tfvars -lock=false