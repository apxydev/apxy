# Debugging Mobile App Traffic

Mobile apps and simulators often hide failing API calls behind generic error toasts. By routing the device through APXY on your Mac or Linux machine, you capture the real requests and responses -- TLS included once the CA is trusted -- without adding logging code to the app.

**Difficulty**: Beginner | **Time**: ~10 minutes | **Features used**: Mobile setup, Traffic inspection, SSL interception, QR provisioning | **Requires**: Free

## Scenario

You are shipping an iOS or Android app that talks to your backend. A screen shows "Something went wrong" but Xcode or Logcat does not show the full HTTP exchange. You need the same visibility you get on desktop: status codes, headers, JSON bodies, and timing -- captured from a physical phone or emulator on the same Wi‑Fi as your laptop.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux on your development machine
- AI coding agent with APXY skill installed
- Mobile device or simulator on the **same LAN** as the dev machine (no guest-network isolation)
- For HTTPS: willingness to install APXY's CA on the device (see SSL guide)

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.myapp.com"

**Your agent runs:**

```bash
apxy start --ssl-domains api.myapp.com
```

If you haven't set up APXY's CA certificate yet, see
[SSL Setup Guide](../ssl-setup-guide/) first.

---

## Track A: Agent + CLI Workflow

> Best for: copy-paste proxy host/port values and scripted verification.

### Step 1: Start the proxy and discover your LAN IP

Tell your agent:

> "Start APXY for mobile debugging on the default port and show me the LAN address I should type on my phone."

Your agent runs:

```bash
apxy start --ssl-domains api.myapp.com
```

Agent shows something like:

```
APXY proxy running on :8080
Web UI available at http://127.0.0.1:8082
  LAN address: 192.168.1.42:8080  (use this on mobile devices)
Mobile setup available on LAN at port 8083
```

Note the **proxy host** (`192.168.1.42`) and **proxy port** (`8080` unless you passed `--port` to `apxy start`). Your device Wi‑Fi proxy must use this host and port. The **mobile setup** line is a separate LAN port (often `Web UI port + 1` when the UI binds to localhost) so your phone can open setup pages without changing `--listen-addr`.

### Step 2: Print mobile setup instructions (and optional QR)

Tell your agent:

> "Show me the full mobile setup steps and a QR code for the setup page."

Your agent runs:

```bash
apxy setup mobile setup --port 8080 --qr
```

`--port` must match the proxy listen port from Step 1. Agent prints an ASCII QR code (when LAN IP detection works) and step-by-step text for iOS and Android.

**Prefer the LAN mobile URL from proxy startup:** open `http://<LAN-IP>:<mobile-setup-port>/mobile-setup` in the phone browser, where `<mobile-setup-port>` is the value from `Mobile setup available on LAN at port ...` in Step 1 (example: `8083` when the Web UI is on `8082`).

After the device Wi‑Fi proxy points at APXY, Safari/Chrome on the phone can also open **`http://apxy.proxy/ssl`** to download the CA -- this hostname is resolved via the proxy to the cert endpoint (same flow printed by `apxy setup mobile setup`).

### Step 3: Configure the device Wi‑Fi proxy

On **iOS**: Settings → Wi‑Fi → (i) on your network → Configure Proxy → Manual → Server `192.168.1.42`, Port `8080`.

On **Android**: Settings → Network → Wi‑Fi → Advanced / Proxy → Manual → same host and port.

Tell your agent:

> "Summarize iOS vs Android proxy fields so I can double-check my device."

Agent repeats the table from `apxy setup mobile setup` output with your actual LAN IP filled in.

### Step 4: Install and trust the CA on the device

Tell your agent:

> "Walk me through trusting APXY's CA on iOS and Android for HTTPS debugging."

Your agent runs on the dev machine (if you still need the cert file path):

```bash
apxy certs info
```

On **iOS**: Open the mobile setup URL or AirDrop/email the `.crt`, install the profile, then Settings → General → About → Certificate Trust Settings → enable full trust for APXY.

On **Android**: Install the CA from the setup page or `apxy certs` path as a user credential (nougat+ may require "Install from storage" in security settings). Some OEMs need a lock screen PIN first.

Agent reminds you: **public apps in production must never ship with user-trusted MITM CAs** -- this is dev-only.

### Step 5: Capture traffic from the app

Tell your agent:

> "I'll launch the app now -- tell me how to confirm APXY is seeing the traffic."

Open your app and navigate to screens that call `api.myapp.com`. In parallel, your agent runs:

```bash
apxy logs list --limit 20
```

Agent shows rows with your API host, methods, and status codes as requests hit the proxy.

Example:

```
ID   METHOD  URL                                      STATUS  DURATION
12   GET     https://api.myapp.com/v1/me              200     134ms
11   POST    https://api.myapp.com/v1/session         401     89ms
```

### Step 6: Inspect a failing mobile request

Tell your agent:

> "Show me full details for the latest 401 from api.myapp.com."

Your agent runs:

```bash
apxy logs list --limit 5
apxy logs show --id 11
```

Agent reports request headers (including `Authorization` if present), request body, response headers, JSON error payload, and timing -- the same detail you would get for desktop traffic.

### Step 7: Clean up proxy settings

When finished, disable the Wi‑Fi manual proxy on the device so normal browsing does not depend on your laptop. Tell your agent:

> "Stop APXY."

Your agent runs:

```bash
apxy stop
```

---

## Track B: Web UI Workflow

> Best for: QR-driven setup and visual inspection of mobile traffic.

### Step 1: Start the proxy and open Mobile Setup

With the proxy running, open **http://localhost:8082** on your computer. Go to **Mobile Setup** (or the onboarding card that links to it).

> screenshots/01-webui-mobile-setup.png

### Step 2: Use QR code and manual instructions

Scan the **QR code** with the phone camera; it should open the LAN setup page with proxy host, port, and certificate download links. If QR fails, use the **manual** host/port fields shown on the same page.

> screenshots/02-mobile-qr-manual.png

### Step 3: Confirm traffic in the Traffic tab

On the device, exercise the app. In the Web UI, go to **Traffic** and filter by your API host. You should see the same requests as in `apxy logs list`, with click-through detail for bodies after SSL interception is trusted.

> screenshots/03-traffic-from-mobile.png

### Step 4: Stop the proxy

Use the UI status control or terminal:

```bash
apxy stop
```

Remember to clear the device Wi‑Fi proxy.

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- LAN proxy + `apxy setup mobile setup`: 0:00 - 3:30
- CA install iOS/Android: 3:30 - 6:30
- Inspecting traffic in UI + CLI: 6:30 - 10:00

---

## What You Learned

- How to pair `apxy start` with `apxy setup mobile setup` for IP, port, and QR
- How to configure iOS and Android Wi‑Fi manual HTTP proxies toward your dev machine
- How to install APXY's CA so HTTPS from the device decrypts inside APXY
- How to list and inspect mobile-originated requests with `apxy logs list` / `apxy logs show` or the **Traffic** tab
- Why you must remove proxy settings and stop the proxy when debugging is done

## Next Steps

- [Setting Up HTTPS Interception](../ssl-setup-guide/) -- deep dive on CA generation, trust, and `--ssl-domains`
- [Debug CORS Errors](../../debug-cors-errors/) -- when browsers or WebViews add CORS complexity on top of mobile APIs
- [Mock Backend for Frontend](../../mock-backend-for-frontend/) -- serve stable responses while the native app is in flux
