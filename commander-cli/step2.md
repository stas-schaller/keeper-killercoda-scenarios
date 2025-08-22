# Step 2: Authentication & Basic Commands

Now that you're connected to the Keeper Commander shell, let's authenticate and explore some basic commands.

## 🔐 Authentication

First, you need to log in to your Keeper account. This will prompt you for your email and master password.

```bash
login
```
`login`{{execute}}

**Note**: You'll be prompted to enter:
- Your Keeper account email address
- Your master password
- Two-factor authentication code (if enabled)

## Troubleshooting Connection Issues

If you encounter connection problems:

- **Check Data Center**: Ensure you're connecting to the correct regional server
- **Network Access**: Verify your network allows HTTPS connections to Keeper servers
- **Credentials**: Double-check your email address and master password
- **2FA**: Ensure your two-factor authentication device is available

**⚠️ Security Reminder**: This is a learning environment. Use test credentials only!

## 👤 Verify Your Identity

After logging in, confirm your authentication status and account information:

```bash
whoami
```
`whoami`{{execute}}

This command displays:
- Your account email
- Current session information
- Account status and permissions

## 📋 Explore Your Vault

### List All Records
View all records in your vault with detailed information:

```bash
ls -l
```
`ls -l`{{execute}}

### Basic Listing
For a simpler view of your records:

```bash
ls
```
`ls`{{execute}}


## 📊 Understanding the Output

When you run `ls -l`{{execute}}, you'll see columns showing

### Folders
- **Folder  UID**: The  UID of your folder
- **Name**: The name of your folder
- **Flags**: The folder's flags, such as 'S' for shared
- **Parent  UID**: The parent folder's UID

### Files
- **Record  UID**: The  UID of your record
- **Type**: The type of the record
- **Title**: The title of the record
- **Description**: Additional information about the record


## 🔍 Additional Useful Commands

### Search for Records
Find specific records by title or content:

```bash
search <search_term>
```

### Get Help
View available commands and their usage:

```bash
help
```
`help`{{execute}}


## 🎯 Next Steps

Once you're comfortable with these basic commands, you can:
- Navigate through folders using `cd`
- Create new records with `add`
- Edit existing records with `edit`
- Share records with team members
- Generate secure passwords

## 🚪 Exiting Commander

When you're finished, you can exit the Commander shell:

```bash
quit
```
`quit`{{execute}}

Great job! You've successfully learned the basics of Keeper Commander CLI. These commands form the foundation for more advanced vault management and automation tasks.