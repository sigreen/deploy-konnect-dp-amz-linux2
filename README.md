Installing Konnect Dataplanes on Amazon Linux 2 with Terraform & Ansible
===========================================================

This example stands up two Amazon Linux 2 instances using Terraform, then provisions a Kong Konnect dataplane on each instance using an Ansible playbook

## Prerequisites
1. AWS Credentials (stored in ~/.aws )
2. AWS Private Key Pair for SSH
3. Terraform CLI
4. Konnect Cloud login (https://cloud.konghq.com/)

## Procedure

1. Via the CLI, login to AWS using `aws configure`.
2. Open `tf/variables.tf` and update the PATH_TO_PRIVATE_KEY to match your AWS keypair (SSH) name
3. Copy and paste the cluster cert + key from Konnect into the associated files in `/ansible`
4. Update `/ansible/kongdp.yaml` with your Konnect username, password and runtime ID.
5. In `tf/main.tf`, update the Tags/Name to something unique that identifies you.
6. Via the CLI, run the following Terraform commands to standup Amazon Linux 2:

```bash
terraform init
terraform apply
```
7. Once Terraform has completed, test each dataplane using the public_ip that is printed out to the CLI:

```bash
curl http://<public_ip>:8000/
```