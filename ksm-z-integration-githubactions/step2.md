### Step 2: Configure and Use KSM in GitHub Action

Now that you have your KSM Application Configuration stored as a GitHub secret, you can use the `Keeper-Security/ksm-action` in your GitHub Actions workflow to fetch secrets from your Keeper Vault.

**1. Add the Keeper Secrets Manager Action to Your Workflow**

In your new or existing GitHub Action workflow file (e.g., `.github/workflows/main.yml`), add the following step. This step will retrieve specified secrets and make them available to subsequent steps in your job.

```yaml
      - name: Retrieve secrets from KSM
        id: ksmsecrets # An id to refer to the step's outputs if needed
        uses: Keeper-Security/ksm-action@master # Always consider using a specific version tag for production
        with:
          # This references the GitHub repository secret you created in Step 1
          keeper-secret-config: ${{ secrets.KSM_CONFIG_JSON }} 
          
          # Define which secrets to fetch and how to map them
          # Replace UIDs and paths with your actual secret UIDs and desired mappings
          secrets: |
            # Example 1: Map a record field to a step output (default behavior)
            RECORD_UID_1/field/password > API_KEY_OUTPUT 
            
            # Example 2: Map a record field to an environment variable
            RECORD_UID_2/custom_field/signing.keyId > env:SIGNING_KEY_ID
            
            # Example 3: Map a file to a path in the runner
            RECORD_UID_3/file/private-key.asc > file:/tmp/signing_secret_key_ring_file.asc
            
            # Example 4: Map another field to an environment variable for demonstration
            RECORD_UID_4/field/login > env:APP_LOGIN

      # Example of using the fetched secrets in subsequent steps
      - name: Use Fetched Secrets
        run: |
          echo "API Key from step output: ${{ steps.ksmsecrets.outputs.API_KEY_OUTPUT }}"
          echo "Signing Key ID from env: $SIGNING_KEY_ID"
          echo "App Login from env: $APP_LOGIN"
          if [ -f /tmp/signing_secret_key_ring_file.asc ]; then
            echo "Signing key file exists at /tmp/signing_secret_key_ring_file.asc"
          else
            echo "Signing key file NOT found at /tmp/signing_secret_key_ring_file.asc"
          fi
```

**2. Understanding the `secrets` Mapping**

The `secrets` input is a multi-line string where each line defines a secret to fetch using [Keeper Notation](https://docs.keeper.io/secrets-manager/secrets-manager/about/keeper-notation) and its destination within the GitHub Actions runner:

-   **`KEEPER_NOTATION > SECRET_NAME` (Default - Step Output)**: Fetches the secret (field or custom field value) and makes it available as an output of the `ksmsecrets` step. You can reference it in subsequent steps using `${{ steps.ksmsecrets.outputs.SECRET_NAME }}`.
    -   Example: `RECORD_UID_1/field/password > API_KEY_OUTPUT` fetches the password field from `RECORD_UID_1` and makes it available as `steps.ksmsecrets.outputs.API_KEY_OUTPUT`.

-   **`KEEPER_NOTATION > env:ENV_VARIABLE_NAME` (Environment Variable)**: Fetches the secret value and sets it as an environment variable named `ENV_VARIABLE_NAME` for subsequent steps in the current job.
    -   Example: `RECORD_UID_2/custom_field/signing.keyId > env:SIGNING_KEY_ID` fetches the custom field `signing.keyId` from `RECORD_UID_2` and sets it as the environment variable `SIGNING_KEY_ID`.

-   **`KEEPER_NOTATION > file:FILEPATH` (File)**: For `field` or `custom_field` types, this saves the secret's value into the specified `FILEPATH`. For `file` notation (e.g., `RECORD_UID/file/FILENAME.EXT`), it downloads the file from the Keeper record and saves it to `FILEPATH` on the GitHub Actions runner.
    -   Example: `RECORD_UID_3/file/private-key.asc > file:/tmp/signing_secret_key_ring_file.asc` fetches the file named `private-key.asc` from `RECORD_UID_3` and saves it to `/tmp/signing_secret_key_ring_file.asc`.

**Important:**
-   **Replace Placeholders**: Ensure you replace `RECORD_UID_1`, `RECORD_UID_2`, `RECORD_UID_3`, `RECORD_UID_4`, and the specific field/file notations with those relevant to your Keeper Vault records.
-   **Case Sensitivity for Outputs**: When mapping to step outputs (default), the `SECRET_NAME` you define (e.g., `API_KEY_OUTPUT`) is case-sensitive and is used to access the output later (e.g., `steps.ksmsecrets.outputs.API_KEY_OUTPUT`).
-   **Official Documentation**: For comprehensive details on all notation options (standard fields, custom fields, files, etc.) and advanced usage, refer to the [official Keeper Secrets Manager GitHub Action documentation](https://docs.keeper.io/secrets-manager/secrets-manager/integrations/github-actions).

After adding this step to your workflow and committing the changes, your GitHub Action will securely fetch the defined secrets from Keeper Secrets Manager each time it runs, making them available as step outputs, environment variables, or files as configured.