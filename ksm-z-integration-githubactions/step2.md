In the new or existing GitHub Action add following action:

```yaml
      - name: Retrieve secrets from KSM
        id: ksmsecrets
        uses: Keeper-Security/ksm-action@master
        with:
          keeper-secret-config: ${{ secrets.KSM_CONFIG_JSON }}
          secrets: |
            zOVOneDczofWFlfizjC5Qw/file/private-key.asc > file:/tmp/signing_secret_key_ring_file.asc
            zOVOneDczofWFlfizjC5Qw/custom_field/signing.keyId > env:SIGNING_KEY_ID
            zOVOneDczofWFlfizjC5Qw/custom_field/signing.password > env:SIGNING_PASSWORD
            zOVOneDczofWFlfizjC5Qw/custom_field/ossrhUsername > env:OSSRH_USERNAME
            zOVOneDczofWFlfizjC5Qw/custom_field/ossrhPassword > env:OSSRH_PASSWORD
```

`secrets` section defines what secrets to retrieve and where to place them. See our official documentation for more details [HERE](https://docs.keeper.io/secrets-manager/secrets-manager/integrations/github-actions)