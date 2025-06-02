# Step 1: Setup & Connect to Keeper

## Understanding Keeper Data Centers

Keeper Security operates multiple data centers around the world to ensure optimal performance and compliance with local data residency requirements. Before connecting, you need to specify which data center hosts your Keeper account.

## Connecting to Your Data Center

Choose the appropriate command based on your account's data center location:

### 🇺🇸 United States (Default)
```bash
keeper shell
```
`keeper shell`{{execute}}

### 🇪🇺 European Union
```bash
keeper shell --server keepersecurity.eu
```
`keeper shell --server keepersecurity.eu`{{execute}}

### 🇦🇺 Australia
```bash
keeper shell --server keepersecurity.com.au
```
`keeper shell --server keepersecurity.com.au`{{execute}}

### 🏛️ US Government Cloud
```bash
keeper shell --server govcloud.keepersecurity.us
```
`keeper shell --server govcloud.keepersecurity.us`{{execute}}

### 🇨🇦 Canada
```bash
keeper shell --server keepersecurity.ca
```
`keeper shell --server keepersecurity.ca`{{execute}}

### 🇯🇵 Japan
```bash
keeper shell --server keepersecurity.jp
```
`keeper shell --server keepersecurity.jp`{{execute}}

## What Happens Next?

Once you execute the appropriate command:

1. **Connection Established**: Commander will connect to your specified data center
2. **Interactive Shell**: You'll enter the Keeper Commander interactive shell
3. **Authentication Required**: You'll need to log in with your credentials
4. **Ready to Use**: After authentication, you can execute Keeper commands

## Troubleshooting

- **Connection Issues**: Ensure you're using the correct server for your account
- **Authentication Problems**: Verify your credentials and account status
- **Network Errors**: Check your internet connection and firewall settings

Click **Next** when you're ready to proceed with authentication and basic commands!
