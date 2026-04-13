# Troubleshooting

## Installation Issues

### macOS blocks the binary ("unidentified developer")

Official release binaries are signed and notarized -- this should not happen. If it does:

```bash
xattr -d com.apple.quarantine ./apxy
```

Or go to **System Settings > Privacy & Security**, find the APXY message, and click **Allow Anyway**.

---

## Runtime Issues

### Certificate not trusted (HTTPS errors)

```bash
# Regenerate and re-trust the CA
rm -rf certs/
apxy start
# macOS will prompt for your password to trust the new CA
```

Or manually:

```bash
apxy certs generate
sudo apxy certs trust
```

For Linux:

```bash
sudo cp certs/ca.crt /usr/local/share/ca-certificates/apxy-ca.crt
sudo update-ca-certificates
```

### Port already in use

```bash
# Find what's using the port
lsof -i :8080

# Kill it
kill $(lsof -ti :8080)

# Or use a different port
apxy start --port 9090
```

### Proxy starts but HTTPS requests fail

1. Verify the CA exists: `apxy certs info`
2. Verify the cert path: `ls -la certs/`
3. Try regenerating: `rm -rf certs/ && apxy certs generate`

### No traffic being captured

1. Check the proxy is running: `curl -x http://localhost:8080 http://httpbin.org/get`
2. Verify with verbose: `apxy start --verbose`
3. On Linux, ensure env vars are set: `echo $http_proxy`

### Mock rules not matching

1. Check `apxy mock list` to verify the rule exists and is enabled
2. Verify the URL pattern. Match type matters:
   - `exact`: `/api/users` matches only `/api/users`
   - `wildcard`: `/api/*` matches `/api/users`, `/api/posts`
   - `regex`: `/api/users/\d+` matches `/api/users/123`
3. Run with `--verbose` to see matching attempts

### Web UI not loading

- Ensure the binary includes the embedded frontend (official releases do)
- Check that `--web-port` is not set to `0`
- Try accessing `http://localhost:<port+2>` directly

### System proxy not restored after crash

If APXY crashes without cleanup, the system proxy may remain configured:

```bash
# macOS: disable manually
networksetup -setwebproxystate "Wi-Fi" off
networksetup -setsecurewebproxystate "Wi-Fi" off

# Or run apxy stop (it disables system proxy as a safety net)
apxy stop
```

---

## Getting More Help

- [Open an issue](https://github.com/apxydev/apxy/issues)
- Run with `--verbose` flag for detailed logs
- Check `apxy version` to ensure you're on the latest release
