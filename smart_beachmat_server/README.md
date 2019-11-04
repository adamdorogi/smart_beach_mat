# TODO
- Custom exceptions with fixed status code and message.
- Verify email/password functions

# Troubleshooting
## MySQL authentication error
`mysqli_real_connect(): The server requested authentication method unknown to the client [caching_sha2_password]`

Fix:
- `alter user 'YOUR_USERNAME'@'localhost' identified with mysql_native_password by 'YOUR_PASSWORD';`

## MySQL authentication error 2
`mysqli_real_connect(): (HY000/2002): No such file or directory`

Fix:
- Start MySQL server in System Preferences.

# Enable `.htaccess`
In the `/etc/apache2/httpd.conf` file, change:
```
<Directory "/your/web/server/">
    ...
    AllowOverride none
    ...
</Directory>
```

To:
```
<Directory "/your/web/server/">
    ...
    AllowOverride All
    ...
</Directory>
```

# Enable `mod_rewrite`
In the `/etc/apache2/httpd.conf` file, uncomment `LoadModule rewrite_module libexec/apache2/mod_rewrite.so`.

# PHP Notes/Tips
- Get specific header value:
  ```
  $headers = getallheaders();
  $headers['authorization'];
  ```
- Get POST body:
  ```
  var_dump($_POST)
  ```