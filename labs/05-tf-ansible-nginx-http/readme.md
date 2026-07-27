# Terraform + ansible + nginx = Working web server

1. Create a EC2 instance using terraform
2. Configure the EC2 instance to run nginx using ansible
3. Then get the `public_ip` using `terraform output -raw public_ip`
4. Visit the site

> NOTE: This project works only on HTTP, Check another lab for HTTPS
