
Create `package.json`

<pre class="file" data-filename="package.json" data-target="replace">
{
  "name": "ksm-aws-lambda-helloworld",
  "scripts": {
    "bundle-lambda": "webpack",
    "deploy": "npm run bundle-lambda && cdk deploy"
  },
  "dependencies": {
    "@keeper-security/secrets-manager-core": "^16.2.3"
  },
  "devDependencies": {
    "aws-sdk": "^2.1080.0"
  }
}
</pre>

Create the function code:


<pre class="file" data-filename="index.js" data-target="replace">
const {
    loadJsonConfig,
    getSecrets
} = require("@keeper-security/secrets-manager-core");

const AWS = require("aws-sdk");

const AWS_SECRET_KSM_CONFIG_SECRET_NAME = 'prod/sample/key'; // Name of the Secret that was created in AWS Secrets Manager and to which this Lambda function has access
const AWS_REGION = 'us-east-2';                              // Make sure to use the correct AWS region

exports.handler = async (event) => {

    // Collect all records from KSM.
    // This is just an example of how to get secrets.
    // In real code you should never return these secrets,
    // unless you know what you are doing
    let allRecords = await getAllRecords();

    return {
        statusCode: 200,
        body: JSON.stringify(allRecords)
    };
};


async function getAllRecords() {

    // Getting KSM Config string from AWS Secrets Manager
    let awsSecret_ksmConfigStr = await getAWSSecret(AWS_SECRET_KSM_CONFIG_SECRET_NAME, AWS_REGION);

    let records = {}

    if (awsSecret_ksmConfigStr !== undefined){

        const awsSecret_ksmConfig = JSON.parse(awsSecret_ksmConfigStr);

        const options = { storage: loadJsonConfig(awsSecret_ksmConfig.KSM_CONFIG) }

        records = await getSecrets(options)

    } else {
        console.error("KSM Config AWS Secret was empty")
    }

    return records
}


/**
 * HELPER TO GET AWS SECRETS
 * Uses AWS Secrets Manager to retrieve a secret
 * Source: https://dev.to/aws-builders/how-to-use-secrete-manager-in-aws-lambda-node-js-3j80
 */
async function getAWSSecret (secretName, region){
    const config = { region : region }
    let secret, decodedBinarySecret;
    let secretsManager = new AWS.SecretsManager(config);
    try {
        let secretValue = await secretsManager.getSecretValue({SecretId: secretName}).promise();
        if ('SecretString' in secretValue) {
            return secret = secretValue.SecretString;
        } else {
            let buff = new Buffer(secretValue.SecretBinary, 'base64');
            return decodedBinarySecret = buff.toString('ascii');
        }
    } catch (err) {
        console.error(err.toString())
        // Handle error properly here
    }
}
</pre>

### Build

`npm install`{{execute}}

### Create a deployment package

`zip -r --exclude="node_modules/aws-sdk/*" ksm-function.zip *`{{execute}}

### Upload the function code to AWS Lambda

```
aws lambda create-function --function-name my-ksm-function \
--zip-file fileb://ksm-function.zip --handler index.handler --runtime nodejs12.x \
--role arn:aws:iam::$(aws sts get-caller-identity --query "Account" --output text):role/lambda-ex
```{{execute}}






