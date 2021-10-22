
## Initialize the Client Device

The CLI is initialized by passing in the One-Time Access Token when the Client Device was created. 
After initialization, the CLI can be used to obtain secrets.  In the example below, replace "XX:XXXX"
with the One-Time Access Token for your Client Device.

`ksm profile init --token XX:XXXX`{{copy}}

## List All Secrets

`ksm secret list`{{execute}}

## Get Individual Secret

`ksm secret get [UID]`{{copy}}

For more commands and options you can see our documentation [HERE](https://docs.keeper.io/secrets-manager/secrets-manager/secrets-manager-command-line-interface)

In the next step, you will see how to configure access to KSM CLI using already initialized config json as an environment variable
