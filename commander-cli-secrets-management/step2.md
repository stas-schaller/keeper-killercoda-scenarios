### List all available applications

`secrets-manager app list`{{execute}}

### Get application by name
Copy line below and replace `[APP NAME or UID]` with the application name listed after running command above

`secrets-manager app get [APP NAME or UID]`{{copy}}

### Create application

`secrets-manager app create SampleApplication`{{execute}}

### Remove application

`secrets-manager app remove SampleApplication --purge`{{execute}}