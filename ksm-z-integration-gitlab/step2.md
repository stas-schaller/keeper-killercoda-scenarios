### Step 2: Using KSM CLI in GitLab CI/CD Pipelines

With your `KSM_CONFIG` variable set in GitLab (as covered in Step 1), you can now write a `.gitlab-ci.yml` pipeline definition to install the Keeper Secrets Manager CLI and use it to fetch secrets.

**1. Create/Update `.gitlab-ci.yml`**

Add the following to your project's `.gitlab-ci.yml` file. If the file doesn't exist, create it in the root of your repository.

```yaml
image: python:latest  # Use an image that has Python 3 and pip

before_script:
  - echo "Updating package list (if needed, often handled by base image)..."
  # - apt-get update -y # Uncomment if your base image needs an update
  - echo "Installing Python3 and pip (if needed, often included in python:latest)..."
  # - apt-get install -y python3 python3-pip # Uncomment if not included
  - echo "Installing Keeper Secrets Manager CLI..."
  - python3 -m pip install keeper-secrets-manager-cli
  - echo "KSM CLI installation complete."
  # If your GitLab CI/CD variable was NOT named KSM_CONFIG, export it here:
  # - export KSM_CONFIG=$YOUR_GITLAB_VARIABLE_NAME 

job1:
  stage: build
  script:
    - echo "Fetching secrets from Keeper..."
    
    # Example 1: Get a password field and set it as an environment variable
    # Replace KEEPER_RECORD_UID_PWD with the actual UID of your record containing a password
    - export MY_APP_PASSWORD=$(ksm secret get keeper://KEEPER_RECORD_UID_PWD/field/password)
    
    # Example 2: Get a custom field value (e.g., an API key stored in a field named 'apiKey')
    # Replace KEEPER_RECORD_UID_APIKEY and custom_field/apiKey with your actual UID and field name
    - export MY_API_KEY=$(ksm secret get keeper://KEEPER_RECORD_UID_APIKEY/custom_field/apiKey)
    
    # Example 3: Download a file attached to a Keeper record
    # Replace KEEPER_RECORD_UID_FILE and FILENAME_IN_KEEPER.txt with your actual UID and filename
    - ksm secret download -u KEEPER_RECORD_UID_FILE --name "FILENAME_IN_KEEPER.txt" --file-output "/tmp/downloaded_file.txt"
    
    # Verify the secrets (for demonstration purposes - avoid echoing sensitive data in real pipelines)
    - echo "MY_APP_PASSWORD (length): ${#MY_APP_PASSWORD}" # Echo length instead of actual password
    - echo "MY_API_KEY: $MY_API_KEY"
    - echo "Checking for downloaded file..."
    - if [ -f /tmp/downloaded_file.txt ]; then echo "File /tmp/downloaded_file.txt downloaded successfully."; else echo "File download FAILED."; fi
    - ls -l /tmp # List contents of /tmp for verification
```

**Explanation:**

-   **`image: python:latest`**: Specifies a Docker image to use for the job. The `python:latest` image typically includes Python 3 and `pip`.
-   **`before_script`**: These commands run before the `script` in each job.
    -   It installs `keeper-secrets-manager-cli` using `pip`.
    -   It includes a commented-out line to show how you would export your KSM configuration if you named the GitLab variable something other than `KSM_CONFIG`.
-   **`job1`**: A sample job.
    -   **`stage: build`**: Assigns the job to the `build` stage (you can define your own stages).
    -   **`script`**: Contains the commands to execute.
        -   `export MY_APP_PASSWORD=$(ksm secret get keeper://KEEPER_RECORD_UID_PWD/field/password)`: This uses a command substitution `$(...)`.
            -   `ksm secret get`: The KSM CLI command to retrieve a secret.
            -   `keeper://KEEPER_RECORD_UID_PWD/field/password`: This is an example of Keeper Notation. You **must** replace `KEEPER_RECORD_UID_PWD` with the actual UID of a Keeper record you have access to that has a password field.
            -   The retrieved password will be stored in the environment variable `MY_APP_PASSWORD`.
        -   The next `export` command shows retrieving a custom field named `apiKey` from another record (`KEEPER_RECORD_UID_APIKEY`).
        -   `ksm secret download ...`: Shows how to download a file attached to a record (`KEEPER_RECORD_UID_FILE`) and save it to `/tmp/downloaded_file.txt` in the job's runner.
        -   The `echo` and `if` commands are for demonstration to verify that the secrets were fetched. **In production pipelines, avoid echoing actual secret values to the logs.**

**2. Commit and Run the Pipeline**

1.  Commit the `.gitlab-ci.yml` file to your repository.
2.  Push the commit to GitLab.
3.  Navigate to **CI/CD > Pipelines** in your GitLab project to see the pipeline run.

If configured correctly, the job log for `job1` should show the KSM CLI commands executing and the verification messages.

This step demonstrates the basic usage of the KSM CLI to securely inject secrets into your GitLab CI/CD environment. You can adapt these examples to fetch any secret type or file needed by your build, test, or deployment scripts. 