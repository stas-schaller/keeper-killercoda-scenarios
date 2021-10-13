### Create folder where Ansible playbooks will be stored:

`mkdir my-playbooks && cd my-playbooks`{{execute}}

### Initialize config file for plugin ot use

`keeper_ansible --keeper_token XX:YYYYYY`{{copy}}

### Create sample Ansible playbook

<pre class="file" data-filename="ksm-sample-playbook.yml" data-target="replace">

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
</pre>

Change `[RECORD UID]` to your record UIDs

### Run Playbook

`ansible-playbook ksm-sample-playbook.yml`{{execute}}

### View password that was inserted into a file

`cat /tmp/my_password`