# roblox-protonvpn

Local, private notes for routing Roblox through Proton VPN. This repo has no remote.

## What already does this

Proton VPN’s Windows app already routes chosen programs through the tunnel. That feature is **split tunneling, Include mode**, on a paid plan. The client is [ProtonVPN/win-app](https://github.com/ProtonVPN/win-app). Setup is documented at [How to use split tunneling](https://protonvpn.com/support/protonvpn-split-tunneling).

No separate project was found that sends Roblox through Proton VPN. [SwiftTunnel](https://github.com/Swift-tunnel/swifttunnel-app) can steer some Roblox traffic, but it sends that traffic to SwiftTunnel relays, not to Proton.

Include mode is the right scope. Roblox’s own network article says game-server addresses are diverse and are not published as a fixed allow-list ([Troubleshooting Education Networks](https://en.help.roblox.com/hc/en-us/articles/115005744663-Troubleshooting-Education-Networks)). A single CIDR such as `128.116.0.0/17` (AS22697) misses CDN and API hosts (`*.rbxcdn.com`, Arkose, and others), so an IP rule does not cover all Roblox traffic. Including the Roblox executables does.

## Include these programs

Roblox replaces `RobloxPlayerBeta.exe` in a new `version-*` folder on update. Re-add the new path after each update. List the current files with:

```powershell
powershell -NoProfile -File .\scripts\Get-RobloxExecutables.ps1
```

Add every path it prints, typically:

- `RobloxPlayerBeta.exe` — game UDP and client HTTPS
- `RobloxPlayerLauncher.exe` — bootstrapper
- `RobloxStudioBeta.exe` — Studio, if you use it

In the Proton VPN app:

1. Open **Split tunneling** and turn it on.
2. Choose **Include mode** (only the selected apps use the VPN).
3. Add the executables from the script.
4. Apply, or reconnect if you are already connected.
5. Quit Roblox completely, then start it again. Include mode does not move sockets that were already open.

From the Windows client 4.3.7 release notes, include mode works with the kill switch: if the VPN drops, traffic from included apps is blocked instead of falling back to the normal connection. Use WireGuard when the profile allows it; it adds less latency than OpenVPN.

Browser tabs on `roblox.com` are not covered by the player executable. Proton’s browser extension can split-tunnel by domain, and that control is for excluding sites from the VPN. To send website traffic through Proton as well, include the browser, which also sends the rest of that browser through the VPN.

## Check that it worked

While a game is running:

```powershell
powershell -NoProfile -File .\scripts\Show-RobloxRoute.ps1
```

Included-app sockets should use the Proton adapter (often a WireGuard or Wintun interface). Sockets on the normal Ethernet or Wi-Fi address are still outside the tunnel. Reading the endpoint tables may require an elevated PowerShell window.
