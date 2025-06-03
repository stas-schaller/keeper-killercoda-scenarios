# GitLab Pipelines

### Step 1: Configure KSM Application & GitLab CI/CD Variable

To enable your GitLab CI/CD pipelines to securely access secrets from Keeper, you first need a KSM Application Configuration. This configuration acts as the credential for your pipeline jobs to authenticate with Keeper Secrets Manager.

**1. Generate KSM Application Configuration**

This tutorial assumes you have already generated a KSM Application Configuration (either in JSON or Base64 format) using Keeper Commander or the Keeper Vault. If you haven't, please refer to the [Keeper Secrets Manager Configuration documentation](https://docs.keeper.io/secrets-manager/secrets-manager/about/secrets-manager-configuration) for instructions on creating one. 

For this Katacoda scenario, we will use a pre-generated configuration. In a real-world scenario, you would generate this for your specific application/pipeline.

**Treat this configuration string as a sensitive secret.**

**2. Store the KSM Configuration as a GitLab CI/CD Variable**

In your GitLab project:
1. Navigate to **Settings > CI/CD**.
2. Expand the **Variables** section.
3. Click **Add variable**.

![](./assets/img.png)

4. Fill in the variable details:
   - **Key**: Enter `KSM_CONFIG`. Using this specific key allows the KSM SDKs and CLI to automatically recognize and use the configuration. If you use a different key, you'll need to export it as an environment variable named `KSM_CONFIG` in your pipeline script (e.g., `export KSM_CONFIG=$YOUR_CUSTOM_KEY_NAME`).
   - **Value**: Paste your KSM Application Configuration string (JSON or Base64 format).
   - **Flags**:
     - Check **Protect variable**: This makes the variable available only to pipelines running on protected branches or protected tags. This is crucial for production secrets.
     - Check **Mask variable**: This attempts to hide the variable's value in job logs. While GitLab does its best, be aware that complex, multi-line values might not always be fully masked.

> **Important Security Note**: Always enable "Protect variable" for sensitive configurations. "Mask variable" adds an extra layer of security by obscuring the value in job logs.

![](./assets/img_2.png)

5. Click **Add variable**.

Your variable will now be listed:

![](./assets/img_3.png)

With the `KSM_CONFIG` variable securely stored in GitLab, your CI/CD pipeline can now be configured to use the Keeper Secrets Manager CLI to fetch secrets.

In the next step, we'll set up a `.gitlab-ci.yml` file to install the KSM CLI and retrieve secrets.

In order to use Keeper Secrets Manager CLI tool, first we need to install it from PyPi registry.
This can be achieved by adding following line to the `before_script:` area:

```yaml
before_script:
- python3 -V  # Python3 and pip module are required in the image
- python3 -m pip install keeper-secrets-manager-cli
```


Inject Field Secret value into environment variable using Keeper Notation:

```yaml
- export MY_PWD=$(ksm secret notation keeper://6ya_fdc6XTsZ7i7x9Jcodg/field/password)
```

Inject Custom Field value:

```yaml
- export MY_ISBNCODE=$(ksm secret notation keeper://6ya_fdc6XTsZ7i7x9Jcodg/custom_field/isbncode)
```


Download file:

```
- ksm secret download -u 6ya_fdc6XTsZ7i7x9Jcodg --name "mykey.pub" --file-output "/tmp/mykey.pub"
```

In the case above, file will be downloaded to `/tmp/mykey.pub` 

Complete example of the pipeline:

```
image: python:latest

before_script:
  - python3 -V  # Print out python version for debugging
  - python3 -m pip install keeper-secrets-manager-cli

job1:
  stage: build
  script:
    - export MY_PWD=$(ksm secret notation keeper://6ya_fdc6XTsZ7i7x9Jcodg/field/password)
    - export MY_ISBNCODE=$(ksm secret notation keeper://6ya_fdc6XTsZ7i7x9Jcodg/custom_field/isbncode)
    - ksm secret download -u 6ya_fdc6XTsZ7i7x9Jcodg --name "mykey.pub" --file-output "/tmp/mykey.pub"
    - file /tmp/mykey.pub
```

To learn more about Variables in GitLab you can read [HERE](https://docs.gitlab.com/ee/ci/variables/)