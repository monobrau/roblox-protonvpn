# Fail closed

Include mode cannot do this. Its driver runs only while Proton is connected, and a Roblox update points `RobloxPlayerBeta.exe` at a new folder that is not on the include list. In both cases the game uses the normal adapter and your real address.

Two locks, both required:

1. Proton is a full tunnel with **Advanced kill switch** on and **split tunneling off**.
2. Windows Firewall blocks every `Roblox*.exe` on every adapter whose name or description does not contain `Proton`.

While Proton is disconnected there is no Proton adapter, so the firewall drops the game client. A new executable after an update is blocked on Ethernet, Wi-Fi, and any other VPN adapter as soon as the refresh runs. The game only has a path out when an adapter named like Proton VPN, ProtonVPN, or TAP-ProtonVPN is up.

Advanced kill switch covers what the firewall rule does not: the browser, the in-game WebView, and the minute before a newly installed executable is picked up. Proton’s filters stay on across reboot. If you never connect, the PC has no internet, so nothing can leak. Split tunneling has to stay off. With it on, any process that is not on the include list, including a WebView host, uses the normal connection while Proton is up.

## Turn the locks on

In the Proton VPN app:

1. Settings → Split tunneling → off.
2. Kill switch → **Advanced** → Apply.
3. Protocol WireGuard. Connect, or turn on connect at startup.

That app setting is not stored by this repo. Proton’s settings file also holds the VPN key, so these scripts do not edit it.

Then, in an elevated window, from this repo:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Sync-RobloxFailClosed.ps1 -Install
```

Approve the elevation prompt. The script installs outbound block rules and a scheduled task named `roblox-protonvpn-fail-closed` that rebuilds them at logon and every minute.

Remove both with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Sync-RobloxFailClosed.ps1 -Remove
```

## Check

Connect Proton, start a game, then from an elevated window:

```powershell
powershell -NoProfile -File .\scripts\Show-RobloxRoute.ps1
```

Roblox sockets should be on the Proton adapter. With Proton disconnected, the game should fail to connect rather than load.

Any adapter whose name or description does not contain “Proton” is blocked on purpose, including another WireGuard tunnel. If a future Proton adapter does not have “Proton” in its name, the game will also fail to connect. That is the closed failure. Add that adapter name only after you confirm it belongs to Proton.
