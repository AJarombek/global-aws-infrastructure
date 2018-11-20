### Overview

This directory contains all the files used in baking an AMI for the Jenkins server.  Packer is used to build the AMI 
with the help of two provisioners.  The first provisioner is a Bash script and the second is an 
[Ansible](https://www.packer.io/docs/provisioners/ansible-local.html) playbook.

### Files

| Filename                 | Description                                                                                 |
|--------------------------|---------------------------------------------------------------------------------------------|
| `jenkins-image.json`     | Packer image configuration file.  Defines the template AMI, provisioners, and the AMI name  |
| `setup-jenkins-image.sh` | The Bash script provisioner for the AMI.  Installs Ansible                                  |
| `setup-playbook.yml`     | The Ansible playbook provisioner for the AMI.  Installs Java, Jenkins, and NFS for EFS      |
| `build-ami.sh`           | **DEPRECATED**: Used to mount EFS while baking the AMI.  This step is now done as user data |
| `util/`                  | Folder for utility Bash scripts that assisted in baking the AMI                             |