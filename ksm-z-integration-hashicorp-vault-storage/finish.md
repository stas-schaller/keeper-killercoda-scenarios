# Congratulations!

Well done! You've successfully integrated Keeper Secrets Manager (KSM) with HashiCorp Vault.

## ✅ Recap of What You've Learned

*   How to install the KSM plugin for HashiCorp Vault.
*   How to start a HashiCorp Vault server in development mode with the KSM plugin.
*   How to configure the KSM plugin within Vault using your KSM application's Base64 configuration.
*   How to list secrets (records) from your Keeper Vault using Vault CLI commands.
*   How to read specific records and retrieve TOTP codes via Vault.
*   How to create, update, and delete secrets in your Keeper Vault using Vault.
*   How to (optionally) deregister the plugin and stop the Vault server.

## Next Steps & Further Learning

*   **Explore Vault Policies**: Learn how to use HashiCorp Vault's policy system to define fine-grained access controls for secrets managed by the KSM plugin.
*   **Production Vault Setup**: This tutorial used Vault in `-dev` mode. For production environments, you'll need to register the plugin with a SHA256 hash and run Vault in a non-dev server mode. Refer to the [Official Keeper HashiCorp Vault Integration Guide](https://docs.keeper.io/en/keeperpam/secrets-manager/integrations/hashicorp-vault#production-mode) for details on production setup.
*   **KSM Features**: Dive deeper into Keeper Secrets Manager features, such as secret rotation, advanced sharing permissions, and various other integrations.
*   **Official Keeper Documentation**:
    *   [Keeper Secrets Manager Documentation](https://docs.keeper.io/secrets-manager/)
    *   [KSM Plugin for HashiCorp Vault Guide](https://docs.keeper.io/en/keeperpam/secrets-manager/integrations/hashicorp-vault)
*   **Official HashiCorp Vault Documentation**:
    *   [HashiCorp Vault Documentation](https://www.vaultproject.io/docs)

We hope this tutorial has been helpful in getting you started with KSM and HashiCorp Vault!

Thank you for using Keeper! w