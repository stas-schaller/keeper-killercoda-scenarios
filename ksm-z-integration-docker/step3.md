#### 1. Connect to DB as `root` user

`mysql -h 127.0.0.1 -P 3306 --protocol=tcp -u root -p`{{execute T2}}

Use password from custom record field labeled `rootpwd`

Type `exit`{{execute}} to leave MySQL shell

#### 2. Connect to DB as a regular user

`mysql -h 127.0.0.1 -P 3306 --protocol=tcp -u [USER NAME] -p`{{execute T2}}

- Use username from the login field of the record
- Use password from the password field of the record