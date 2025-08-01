### Overview

Modules for secrets stored in AWS System Manager Parameter Store.  Currently, secrets stored in Parameter Store are 
account passwords for external websites, basically making Parameter Store a custom password manager.

```bash
# Select Infrastructure Module
cd <module_name>

# Create Infrastructure
terraform init
terraform validate
terraform plan -var 'secret=XXX'
terraform apply -auto-approve -var 'secret=XXX'

# Destroy Infrastructure
terraform destroy -auto-approve
```

### Directories

| Directory Name | Description                                                                              |
|----------------|------------------------------------------------------------------------------------------|
| `aapl`         | Terraform module for an AWS Systems Manager Parameter Store secret with codename `AAPL`. |
| `ally`         | Terraform module for an AWS Systems Manager Parameter Store secret with codename `ALLY`. |
| `coin`         | Terraform module for an AWS Systems Manager Parameter Store secret with codename `COIN`. |
| `dbrx`         | Terraform module for an AWS Systems Manager Parameter Store secret with codename `DBRX`. |
| `fide`         | Terraform module for an AWS Systems Manager Parameter Store secret with codename `FIDE`. |
| `fnra`         | Terraform module for an AWS Systems Manager Parameter Store secret with codename `FNRA`. |
| `gemi`         | Terraform module for an AWS Systems Manager Parameter Store secret with codename `GEMI`. |
| `jbrn`         | Terraform module for an AWS Systems Manager Parameter Store secret with codename `JBRN`. |
| `shwb`         | Terraform module for an AWS Systems Manager Parameter Store secret with codename `SHWB`. |
| `tdam`         | Terraform module for an AWS Systems Manager Parameter Store secret with codename `TDAM`. |
| `vang`         | Terraform module for an AWS Systems Manager Parameter Store secret with codename `VANG`. |