# Step 3: Advanced Playbook Examples

## Database Server Automation with KSM

Let's create a comprehensive playbook that demonstrates advanced KSM usage for database server setup and configuration.

### Create Advanced Database Playbook

```bash
touch playbook-dbserver.yml
```
`touch playbook-dbserver.yml`{{execute}}

### Add the Advanced Playbook Content

Copy this advanced playbook that securely manages database credentials:

```yaml
---
- name: Secure Database Server Setup with KSM
  hosts: 127.0.0.1
  connection: local
  become: true
  gather_facts: true
  
  vars:
    mysql_packages:
      - mysql-server
      - mysql-client
      - python3-pymysql
    
  tasks:
    # Retrieve database credentials from Keeper
    - name: Get MySQL root password from Keeper
      keeper_get:
        uid: [DB_ROOT_RECORD_UID]
        field: password
      register: mysql_root_password
      no_log: true  # Don't log the password
      
    - name: Get application database password from Keeper
      keeper_get:
        uid: [APP_DB_RECORD_UID]
        field: password
      register: app_db_password
      no_log: true
      
    - name: Get database username from Keeper
      keeper_get:
        uid: [APP_DB_RECORD_UID]
        field: login
      register: app_db_user
      
    # Install MySQL packages
    - name: Update package cache
      apt:
        update_cache: yes
        cache_valid_time: 3600
        
    - name: Install MySQL packages
      apt:
        name: "{{ mysql_packages }}"
        state: present
        
    # Configure MySQL service
    - name: Start and enable MySQL service
      systemd:
        name: mysql
        state: started
        enabled: true
        
    # Secure MySQL installation
    - name: Remove test database
      mysql_db:
        name: test
        state: absent
        login_user: root
        login_password: "{{ mysql_root_password.value }}"
        
    - name: Remove anonymous users
      mysql_user:
        name: ''
        host_all: true
        state: absent
        login_user: root
        login_password: "{{ mysql_root_password.value }}"
        
    # Create application database and user
    - name: Create application database
      mysql_db:
        name: myapp
        state: present
        login_user: root
        login_password: "{{ mysql_root_password.value }}"
        
    - name: Create application database user
      mysql_user:
        name: "{{ app_db_user.value }}"
        password: "{{ app_db_password.value }}"
        priv: 'myapp.*:ALL'
        host: '%'
        state: present
        login_user: root
        login_password: "{{ mysql_root_password.value }}"
        
    # Securely store database configuration
    - name: Create secure database config file
      keeper_copy:
        uid: [DB_CONFIG_RECORD_UID]
        field: file
        dest: /etc/mysql/conf.d/secure.cnf
        mode: "0600"
        owner: mysql
        group: mysql
        
    - name: Restart MySQL to apply configuration
      systemd:
        name: mysql
        state: restarted
        
    # Verification tasks
    - name: Verify database connection
      mysql_db:
        name: myapp
        state: present
        login_user: "{{ app_db_user.value }}"
        login_password: "{{ app_db_password.value }}"
      register: db_connection_test
      
    - name: Display connection test result
      debug:
        msg: "Database connection successful!"
      when: db_connection_test is succeeded
```{{copy}}

## SSL Certificate Management Example

Create another playbook for managing SSL certificates:

```bash
touch playbook-ssl-certs.yml
```
`touch playbook-ssl-certs.yml`{{execute}}

### SSL Certificate Playbook

```yaml
---
- name: SSL Certificate Management with KSM
  hosts: 127.0.0.1
  connection: local
  become: true
  
  tasks:
    - name: Create SSL directory
      file:
        path: /etc/ssl/private
        state: directory
        mode: '0700'
        owner: root
        group: root
        
    - name: Copy SSL private key from Keeper
      keeper_copy:
        uid: [SSL_CERT_RECORD_UID]
        field: privateKey
        dest: /etc/ssl/private/server.key
        mode: "0600"
        owner: root
        group: root
        
    - name: Copy SSL certificate from Keeper
      keeper_copy:
        uid: [SSL_CERT_RECORD_UID]
        field: certificate
        dest: /etc/ssl/certs/server.crt
        mode: "0644"
        owner: root
        group: root
        
    - name: Copy SSL certificate chain from Keeper
      keeper_copy:
        uid: [SSL_CERT_RECORD_UID]
        field: certificateChain
        dest: /etc/ssl/certs/server-chain.crt
        mode: "0644"
        owner: root
        group: root
        
    - name: Verify SSL certificate
      openssl_certificate:
        path: /etc/ssl/certs/server.crt
        provider: assertonly
        has_expired: false
      register: cert_check
      
    - name: Display certificate status
      debug:
        msg: "SSL certificate is valid and not expired"
      when: cert_check is succeeded
```{{copy}}

## API Integration Example

Create a playbook for API credential management:

```bash
touch playbook-api-integration.yml
```
`touch playbook-api-integration.yml`{{execute}}

### API Integration Playbook

```yaml
---
- name: API Integration with Secure Credentials
  hosts: 127.0.0.1
  connection: local
  
  tasks:
    - name: Get API key from Keeper
      keeper_get:
        uid: [API_KEY_RECORD_UID]
        field: password
      register: api_key
      no_log: true
      
    - name: Get API endpoint from Keeper
      keeper_get:
        uid: [API_KEY_RECORD_UID]
        field: url
      register: api_endpoint
      
    - name: Test API connection
      uri:
        url: "{{ api_endpoint.value }}/health"
        method: GET
        headers:
          Authorization: "Bearer {{ api_key.value }}"
          Content-Type: "application/json"
        status_code: 200
      register: api_health_check
      
    - name: Display API health status
      debug:
        msg: "API is healthy and accessible"
      when: api_health_check.status == 200
      
    - name: Create application config with API credentials
      template:
        src: app-config.j2
        dest: /opt/myapp/config.json
        mode: '0600'
        owner: myapp
        group: myapp
      vars:
        api_key_value: "{{ api_key.value }}"
        api_endpoint_value: "{{ api_endpoint.value }}"
```{{copy}}

## Configuration Placeholders

**Replace these placeholders with your actual Keeper record UIDs:**

- `[DB_ROOT_RECORD_UID]` - Record containing MySQL root password
- `[APP_DB_RECORD_UID]` - Record containing application database credentials  
- `[DB_CONFIG_RECORD_UID]` - Record containing MySQL configuration file
- `[SSL_CERT_RECORD_UID]` - Record containing SSL certificates
- `[API_KEY_RECORD_UID]` - Record containing API credentials

## Advanced KSM Features Demonstrated

### **Security Best Practices**
- `no_log: true` - Prevents sensitive data from appearing in logs
- Proper file permissions for certificates and keys
- Secure directory creation with restricted access

### **Error Handling**
- Connection verification tasks
- Certificate validation
- API health checks

### **File Management**
- Multiple file types (keys, certificates, configs)
- Proper ownership and permissions
- Template generation with secrets

## Run Advanced Playbooks

Execute the database server playbook:

```bash
ansible-playbook playbook-dbserver.yml
```
`ansible-playbook playbook-dbserver.yml`{{execute}}

**Note**: This will fail without proper record UIDs, but demonstrates the structure.

## Next Steps

In the final step, we'll cover production best practices, security considerations, and deployment strategies for KSM with Ansible.

