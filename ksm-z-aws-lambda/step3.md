


### Create AWS Secret

`aws secretsmanager create-secret --name prod/ksm/config/b64 --description "KSM Scample Config" --secret-string '{"KSM_CONFIG":"[KSM CONFIG Base64 String]"}' --region us-east-2`{{execute}}

Note the value of ARN in output



### Grant AWS Lambda Access to Secrets Manager

1. Create policy file:

<pre class="file" data-filename="read-awssecret.json" data-target="replace">
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "secretsmanager:GetSecretValue"
            ],
            "Resource": [
              "[YOUR_SECRET_ARN]"
            ]
        }
    ]
}
</pre>

2. Attach role policy to the function role

> Before execute command below, replace `[YOUR_SECRET_ARN]` with the ARN from the above Secret creation command

`aws iam put-role-policy --role-name lambda-ex --policy-name ReadAWSSecrets --policy-document file://read-awssecret.json`{{execute}}

Verify that the policy has been applied

`aws iam list-role-policies --role-name lambda-ex`{{execute}}