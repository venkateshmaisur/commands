#### User authentication from Windows Workstation to HDP Realm Using MIT Kerberos Client (with Firefox) 
https://community.cloudera.com/t5/Community-Articles/User-authentication-from-Windows-Workstation-to-HDP-Realm/ta-p/245957

Open Firefox, type about:config in URL and hit enter Search for and change below parameters

```sh
network.negotiate-auth.trusted-uris = .domain.com
network.negotiate-auth.using-native-gsslib = false
network.negotiate-auth.delegation-uris = .domain.com
network.auth.use-sspi = false
network.negotiate-auth.allow-non-fqdn = true
```

#### Configure Mac and Firefox to access HDP/HDF SPNEGO UI
https://community.cloudera.com/t5/Community-Articles/Configure-Mac-and-Firefox-to-access-HDP-HDF-SPNEGO-UI/ta-p/249092


#### Firefox kerberos debug
1. Close all instances of Firefox.
2. In a command prompt, export values for the NSPR_LOG_* variables:
```bash
export NSPR_LOG_MODULES=negotiateauth:5
export NSPR_LOG_FILE=/tmp/moz.log
```
3. Restart Firefox from that shell, and visit the website where Kerberos authentication is failing.
4. Check the /tmp/moz.log file for error messages with nsNegotiateAuth in the message.


* Info: https://www.ietf.org/rfc/rfc2478.txt
