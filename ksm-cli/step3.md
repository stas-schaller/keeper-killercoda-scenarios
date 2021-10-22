##Using KSM CLI with Config from the environment variables

Set config to environment variable with the initialized config

`export KSM_CONFIG=XXXXX`{{copy}}

List secrets:
`ksm secret list`{{execute}}

Get password and store it in env variable:
`export mypwd=$(ksm secret notation keeper://6ya_fdc6XTsZ7i7x9Jcodg/field/password)`{{execute}}

> Print the value: `echo $mypwd`{{execute}}

Download a file:

`ksm secret download -u 6ya_fdc6XTsZ7i7x9Jcodg --name "mykey.pub" --file-output "/tmp/mykey.pub"`{{execute}}

> Check downloaded file: `file /tmp/mykey.pub`{{execute}}
