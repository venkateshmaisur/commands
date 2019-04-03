# RANGER ADMIN LOGIN ISSUE HDP 3.X

1. Change password to default admin/admin using below sql query. 

```mysql
mysql> update ranger.x_portal_user set password = 'ceb4f32325eda6142bd65215f4c0f371' where login_id = 'admin';
```

2. Now you will be able to login to Ranger UI with default username & password i.e. `admin/admin`

If you want to further change password from the default credentials kindly check below steps : 

Goto admin user profile in Ranger UI  --> Select Change password tab --> Put password of your choice and save 

## This step will update new password in ranger db. 

3.  Update new password in ranger configuration, save the changes and restart stale services 

In Ambari, you need to update both "admin_password" and "Ranger Admin user's password for Ambari" with the same values you used in Ranger UI in previous step. 

a.  `Go to Ambari UI ==> Ranger ==> Configs ==> Advanced ranger-env  admin_password` 

b.  `Go to Ambari UI ==> Ranger ==> Configs ==> Admin Settings ranger_admin_password`
