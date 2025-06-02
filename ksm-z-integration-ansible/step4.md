# Step 4: Production Best Practices

## Security Best Practices

### 1. Configuration File Security

Ensure your KSM configuration file is properly secured:

```bash
# Set restrictive permissions
chmod 600 client-config.json

# Verify ownership
ls -la client-config.json
```
`chmod 600 client-config.json && ls -la client-config.json`{{execute}}

### 2. Environment Variable Management

For production deployments, use environment variables instead of files:

```bash
# Export KSM configuration as environment variable
export KSM_CONFIG_BASE64="your_base64_config_here"

# Verify it's set (don't show the actual value)
echo "KSM_CONFIG_BASE64 is set: $([ -n "$KSM_CONFIG_BASE64" ] && echo 'YES' || echo 'NO')"
```
`export KSM_CONFIG_BASE64="demo_config" && echo "KSM_CONFIG_BASE64 is set: $([ -n "$KSM_CONFIG_BASE64" ] && echo 'YES' || echo 'NO')"`{{execute}}

## Production Deployment Strategies

### 1. Ansible Vault Integration

Create a secure playbook that combines Ansible Vault with KSM:

```bash
touch production-secure-playbook.yml
```
`touch production-secure-playbook.yml`{{execute}}

```yaml
---
- name: Production Deployment with KSM and Ansible Vault
  hosts: production_servers
  become: true
  vars_files:
    - vault.yml  # Contains encrypted non-KSM secrets
    
  tasks:
    - name: Get database password from KSM
      keeper_get:
        uid: "{{ vault_db_record_uid }}"  # UID stored in Ansible Vault
        field: password
      register: db_password
      no_log: true
      delegate_to: localhost
      run_once: true
      
    - name: Deploy application with secure database config
      template:
        src: app-config.j2
        dest: /opt/app/config.yml
        mode: '0600'
        owner: app
        group: app
      vars:
        database_password: "{{ db_password.value }}"
        database_host: "{{ vault_db_host }}"  # From Ansible Vault
        
    - name: Restart application service
      systemd:
        name: myapp
        state: restarted
        enabled: true
```{{copy}}

### 2. CI/CD Pipeline Integration

Example GitLab CI configuration:

```yaml
# .gitlab-ci.yml
stages:
  - deploy

deploy_production:
  stage: deploy
  image: ansible/ansible-runner:latest
  before_script:
    - pip install keeper-secrets-manager-ansible
    - export $(keeper_ansible --config)
    - echo "$KSM_CONFIG_BASE64" | base64 -d > client-config.json
    - chmod 600 client-config.json
  script:
    - ansible-playbook -i production_inventory production-playbook.yml
  only:
    - main
  environment:
    name: production
```{{copy}}

### 3. Docker Container Deployment

Create a Dockerfile for containerized Ansible with KSM:

```bash
touch Dockerfile
```
`touch Dockerfile`{{execute}}

```dockerfile
FROM ansible/ansible-runner:latest

# Install KSM plugin
RUN pip install keeper-secrets-manager-ansible

# Set up environment
ENV ANSIBLE_HOST_KEY_CHECKING=False
ENV ANSIBLE_STDOUT_CALLBACK=yaml

# Configure KSM plugin paths
RUN export $(keeper_ansible --config) && \
    echo "export ANSIBLE_LOOKUP_PLUGINS=$ANSIBLE_LOOKUP_PLUGINS" >> /etc/environment && \
    echo "export ANSIBLE_ACTION_PLUGINS=$ANSIBLE_ACTION_PLUGINS" >> /etc/environment

# Copy playbooks
COPY playbooks/ /opt/playbooks/
COPY inventory/ /opt/inventory/

WORKDIR /opt

# Entry point script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
```{{copy}}

## Monitoring and Logging

### 1. Audit Trail Monitoring

Create a playbook to check KSM audit logs:

```bash
touch audit-monitoring.yml
```
`touch audit-monitoring.yml`{{execute}}

```yaml
---
- name: KSM Audit Trail Monitoring
  hosts: localhost
  connection: local
  
  tasks:
    - name: Get recent secret access logs
      uri:
        url: "https://keepersecurity.com/api/rest/audit/event_reports"
        method: POST
        headers:
          Authorization: "Bearer {{ keeper_api_token }}"
        body_format: json
        body:
          command: "audit_event_reports"
          filter:
            created: "{{ ansible_date_time.epoch | int - 3600 }}"  # Last hour
            event_type: "secret_access"
      register: audit_logs
      
    - name: Display recent secret access
      debug:
        msg: "{{ item.message }}"
      loop: "{{ audit_logs.json.audit_event_reports }}"
      when: audit_logs.json.audit_event_reports is defined
```{{copy}}

### 2. Error Handling and Retry Logic

```yaml
---
- name: Robust KSM Integration with Error Handling
  hosts: all
  
  tasks:
    - name: Retrieve secret with retry logic
      keeper_get:
        uid: "{{ secret_uid }}"
        field: password
      register: secret_result
      retries: 3
      delay: 5
      until: secret_result is succeeded
      no_log: true
      
    - name: Handle KSM connection failure
      fail:
        msg: "Failed to retrieve secret after 3 attempts"
      when: secret_result is failed
      
    - name: Use secret in application deployment
      template:
        src: app-config.j2
        dest: /opt/app/config.yml
        mode: '0600'
      vars:
        app_secret: "{{ secret_result.value }}"
      when: secret_result is succeeded
```{{copy}}

## Performance Optimization

### 1. Secret Caching Strategy

```yaml
---
- name: Optimized Secret Retrieval with Caching
  hosts: all
  vars:
    secret_cache: {}
    
  tasks:
    - name: Check if secret is already cached
      set_fact:
        secret_cached: "{{ secret_cache[secret_uid] is defined }}"
        
    - name: Retrieve secret from KSM (if not cached)
      keeper_get:
        uid: "{{ secret_uid }}"
        field: password
      register: secret_result
      when: not secret_cached
      no_log: true
      
    - name: Cache the secret
      set_fact:
        secret_cache: "{{ secret_cache | combine({secret_uid: secret_result.value}) }}"
      when: not secret_cached and secret_result is succeeded
      
    - name: Use cached or fresh secret
      debug:
        msg: "Secret retrieved successfully"
      vars:
        current_secret: "{{ secret_cache[secret_uid] if secret_cached else secret_result.value }}"
```{{copy}}

## Security Checklist

### ✅ **Configuration Security**
- [ ] KSM config file has 600 permissions
- [ ] Config file is not stored in version control
- [ ] Environment variables are used in production
- [ ] Secrets are not logged (`no_log: true`)

### ✅ **Network Security**
- [ ] TLS encryption is enforced
- [ ] Network access is restricted to necessary hosts
- [ ] Firewall rules are properly configured
- [ ] VPN or private networks are used when possible

### ✅ **Access Control**
- [ ] Principle of least privilege is applied
- [ ] Record sharing is properly configured in Keeper
- [ ] Application permissions are regularly reviewed
- [ ] Audit logs are monitored

### ✅ **Operational Security**
- [ ] Regular secret rotation is implemented
- [ ] Backup and recovery procedures are tested
- [ ] Incident response plan includes KSM scenarios
- [ ] Team training on secure practices is conducted

## Troubleshooting Common Issues

### 1. Plugin Not Found Error

```bash
# Verify plugin installation
python3 -c "import keeper_secrets_manager_ansible; print('Plugin installed')"

# Re-export plugin paths
export $(keeper_ansible --config)
echo "Plugin paths configured"
```
`python3 -c "import keeper_secrets_manager_ansible; print('Plugin installed')" && export $(keeper_ansible --config) && echo "Plugin paths configured"`{{execute}}

### 2. Authentication Failures

```bash
# Check config file permissions
ls -la client-config.json

# Verify config file format
python3 -c "import json; json.load(open('client-config.json')); print('Config file is valid JSON')"
```
`ls -la client-config.json`{{execute}}

### 3. Network Connectivity Issues

```bash
# Test connectivity to Keeper servers
curl -I https://keepersecurity.com

# Check DNS resolution
nslookup keepersecurity.com
```
`curl -I https://keepersecurity.com`{{execute}}

## Congratulations! 🎉

You've completed the comprehensive KSM + Ansible integration tutorial! You now know how to:

- ✅ **Install and configure** the KSM Ansible plugin
- ✅ **Create secure playbooks** that retrieve secrets dynamically
- ✅ **Implement advanced scenarios** for databases, SSL, and APIs
- ✅ **Apply production best practices** for security and performance
- ✅ **Handle errors and monitoring** in production environments

### Next Steps for Production

1. **Set up proper secret rotation** schedules in Keeper
2. **Implement monitoring** for secret access and usage
3. **Create backup strategies** for your automation infrastructure
4. **Train your team** on secure automation practices
5. **Regular security audits** of your KSM integration

### Resources

- **KSM Documentation**: [docs.keeper.io](https://docs.keeper.io)
- **Ansible Documentation**: [docs.ansible.com](https://docs.ansible.com)
- **Security Best Practices**: Keeper Security Center
- **Community Support**: Keeper Developer Community

**Happy Automating Securely!** 🔐🚀