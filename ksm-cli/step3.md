##Using KSM CLI with Config from the environment variables

Set config to environment variable with the initialized config

`export KSM_CONFIG=[KSM CONFIG in JSON OR BASE 64]`{{copy}}

List secrets:
`ksm secret list`{{execute}}

Get password and store it in env variable:
`export mypwd=$(ksm secret notation keeper://[RECORD UID]/field/password)`{{copy}}

> Print the value: `echo $mypwd`{{execute}}

Download a file:

`ksm secret download -u [RECORD UID] --name "mykey.pub" --file-output "/tmp/mykey.pub"`{{copy}}

> Check downloaded file: `file /tmp/mykey.pub`{{execute}}
