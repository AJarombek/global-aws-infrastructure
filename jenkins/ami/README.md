### Overview

This directory contains all the files used in baking an AMI for the Jenkins server.  Packer is used to build the AMI 
with the help of two provisioners.  The first provisioner is a Bash script and the second is an 
[Ansible](https://www.packer.io/docs/provisioners/ansible-local.html) playbook.

### Files

| Filename                 | Description                                                                                 |
|--------------------------|---------------------------------------------------------------------------------------------|
| `jenkins-image.json`     | Packer image configuration file.  Defines the template AMI, provisioners, and the AMI name  |
| `setup-jenkins-image.sh` | The Bash script provisioner for the AMI.  Installs Ansible                                  |
| `setup-playbook.yml`     | The Ansible playbook provisioner for the AMI.  Installs Java, Jenkins, NFS for EFS, etc.    |
| `util/`                  | Folder for utility Bash scripts that assisted in baking the AMI                             |

### Resources

[1] [Python3.7 on Ubuntu](https://websiteforstudents.com/installing-the-latest-python-3-7-on-ubuntu-16-04-18-04/)

[2] [Ansible Playbook: Apt Repository](https://docs.ansible.com/ansible/latest/modules/apt_repository_module.html)