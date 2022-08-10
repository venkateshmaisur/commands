
#### reset password
```
ldappasswd -H ldap://localhost -x -D "cn=Manager,dc=pravin,dc=com" -W -S "cn=test,ou=users,dc=pravin,dc=com"


[root@hdp ~]# ldappasswd -H ldap://localhost -x -D "cn=test,ou=users,dc=pravin,dc=com" -W -S "cn=test,ou=users,dc=pravin,dc=com"
New password:
Re-enter new password:
Enter LDAP Password:
[root@hdp ~]# ldappasswd -H ldap://localhost -x -D "cn=test,ou=users,dc=pravin,dc=com" -W -S "cn=test,ou=users,dc=pravin,dc=com"
New password:
Re-enter new password:
Enter LDAP Password:
Result: Constraint violation (19)
Additional info: Password fails quality checking policy
[root@hdp ~]# ldappasswd -H ldap://localhost -x -D "cn=test,ou=users,dc=pravin,dc=com" -W -S "cn=test,ou=users,dc=pravin,dc=com"
New password:
Re-enter new password:
Enter LDAP Password:
Result: Constraint violation (19)
Additional info: Password is not being changed from existing value
```
