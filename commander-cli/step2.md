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

### Show Current Folder
Display your current location in the vault:

```bash
pwd
```
`pwd`{{execute}}

## 📊 Understanding the Output

When you run `ls -l`, you'll see columns showing:
- **Record Title**: The name of your record
- **Login**: Username or email associated with the record
- **URL**: Website or application URL
- **Notes**: Additional information about the record
- **Shared**: Whether the record is shared with others

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