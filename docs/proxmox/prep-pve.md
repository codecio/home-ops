# Bootstrap basic access

Some basic requirements to use the proxmox provider in Terraform.

## SSH

    ssh-copy-id -i ~/.ssh/ansible.pub root@192.168.50.3
    echo "ChallengeResponseAuthentication no\nPasswordAuthentication no\nUsePAM no" > /etc/ssh/sshd_config.d/disable_password_auth.conf