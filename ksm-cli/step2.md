
## Initialize the Client Device

The CLI is initialized by passing in the One Time Access Token when the Client Device was created. 
After initialization, the CLI can be used to obtain secrets.  In the example below, replace "XXXX"
with the One-Time Access Token for your Client Device.

`ksm profile init --host US --token XXXX`{{copy}}

## List All Secrets

`ksm secret list`{{execute}}
