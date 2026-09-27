# roblox-protonvpn

Local, private notes for routing Roblox through Proton VPN. This repo has no remote.

Hand [SETUP.md](SETUP.md) to the person who plays. That is the click-by-click setup.

Proton’s Windows client is [ProtonVPN/win-app](https://github.com/ProtonVPN/win-app). No other project sends Roblox through Proton. SwiftTunnel sends some Roblox traffic to its own relays.

Include mode is not a closed setup. The split-tunnel driver runs only while Proton is connected, and Roblox replaces its executable path on update. Either one sends the game out the normal adapter. An address-range rule also misses CDN and API hosts ([Troubleshooting Education Networks](https://en.help.roblox.com/hc/en-us/articles/115005744663-Troubleshooting-Education-Networks)).

## Fail closed

Use both locks in [docs/fail-closed.md](docs/fail-closed.md):

1. In Proton: split tunneling **off**, kill switch **Advanced**, WireGuard. Forgetting to connect then blocks the whole PC, including the browser and the in-game WebView.
2. Install the firewall refresh once:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Sync-RobloxFailClosed.ps1 -Install
```

That blocks every `Roblox*.exe` on every adapter that is not Proton, including any other VPN adapter. The scheduled task rebuilds the rules at logon and every minute, so a new version folder is blocked without editing an include list. With Proton disconnected, the game has no adapter it is allowed to use.

Why the kill-switch modes differ is in [docs/forgot-to-connect.md](docs/forgot-to-connect.md).

## Check

Connect Proton, start a game, then:

```powershell
powershell -NoProfile -File .\scripts\Show-RobloxRoute.ps1
```

Roblox sockets should be on the Proton adapter. With Proton disconnected, the game should fail to connect. Reading the endpoint table may require an elevated window.
