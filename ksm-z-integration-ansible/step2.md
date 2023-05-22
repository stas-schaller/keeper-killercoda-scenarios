### In CLI navigate to the folder where configuration and playbooks will be stored:

`mkdir my-playbooks && cd my-playbooks`{{execute}}

### Initialize config file for plugin ot use

`keeper_ansible --token [ONE TIME TOKEN]`{{copy}}

### Set correct permissions for the config file, to avoid warnings:

`chmod 600 client-config.json`{{execute}}

### Create sample Ansible playbook

`touch ksm-sample-playbook.yml`{{execute}}

### Edit sample Ansible playbook, copy and paste the following content:

```
---
- name: KSM Plugin Sample Playbook
  hosts: 127.0.0.1
  
  tasks:
    - name: Copy a password to a file
      keeper_copy:
        uid: [RECORD UID]
        field: password
        dest: /tmp/my_password
        mode: "0600"
        
    - name: Get login name 
      keeper_get:
        uid: [RECORD UID]
        field: login      
      register: my_login
        
    - name: Print login name
      debug:
        var: my_login.value
        verbosity: 0
```{{copy}}

Change `[RECORD UID]` to your record UIDs

### Run Playbook

`ansible-playbook ksm-sample-playbook.yml`{{execute}}

### View password that was inserted into a file

`cat /tmp/my_password`{{execute}}
