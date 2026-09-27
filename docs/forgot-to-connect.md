# If Proton is off, Roblox uses your real IP

The setup that stays closed is in [fail-closed.md](fail-closed.md): full tunnel, advanced kill switch, and a firewall block on every non-Proton adapter. The notes below are why include mode does not do that.

Include mode does not block Roblox when the VPN is off. Proton’s split-tunnel driver starts when you connect and stops when you disconnect ([win-app README](https://github.com/ProtonVPN/win-app/blob/master/README.md)). With the driver stopped, `RobloxPlayerBeta.exe` opens sockets on your normal adapter.

This PC has Proton VPN 5.1.8. That is newer than 4.3.7, the release that made Windows split tunneling work with the kill switch.

## What each kill switch covers

Proton documents two modes ([kill switch](https://protonvpn.com/support/what-is-kill-switch), [advanced kill switch](https://protonvpn.com/support/advanced-kill-switch)):

| Situation | Kill switch off | Standard | Advanced |
| --- | --- | --- | --- |
| You never connect | Roblox uses your IP | Roblox uses your IP | No internet at all, so Roblox cannot connect |
| You disconnect on purpose | Roblox uses your IP | Roblox uses your IP | No internet until you connect again or turn advanced off |
| Tunnel drops by accident | Roblox uses your IP | Protected apps are blocked | No internet until Proton reconnects |
| Connected, Include mode | Only listed apps use the tunnel | Same, and a drop blocks protected apps | Same while connected. Other apps stay direct |

Standard kill switch turns on only after a connection is up, and it turns off on a manual disconnect. Forgetting to connect is the same as having no kill switch.

Advanced kill switch is the one that covers that case. It installs persistent Windows Filtering Platform filters that allow internet only through the Proton interface. Those filters stay in place across reboot. On Windows it can stay on together with Include mode. While you are connected, only the listed apps use the tunnel. While you are not, nothing gets out, including Roblox.

The current service code matches that. In `KillSwitch.cs`, leak protection stays on after a normal disconnect only when kill switch mode is Hard (advanced). Full blocking is relaxed to DNS-only leak protection when Include mode (`Permit`) is active and status is `Connected`, so other programs can use the normal connection during a session.

## Setup that fails closed

1. Split tunneling on, Include mode, current Roblox executables from `scripts/Get-RobloxExecutables.ps1`.
2. Kill switch set to **Advanced**, then Apply.
3. Turn on Proton’s connect-at-startup if you want the block to lift without a manual connect. If auto-connect fails, the machine stays offline, which is the safe failure.
4. Quit Roblox and start it only after Proton shows connected.
5. Run `scripts/Show-RobloxRoute.ps1` from an elevated window during a game. Roblox sockets should show the Proton adapter.

Advanced kill switch blocks the whole PC, not only Roblox. That is what stops a forgotten session from leaking. Turn it off only when you intend to use the network without Proton.

Proton’s warning: with advanced kill switch on, a Microsoft account sign-in at the Windows lock screen can fail because it needs the internet. A local Windows account avoids that.

## A leak that advanced kill switch does not close

After a Roblox update, `RobloxPlayerBeta.exe` moves to a new `version-*` folder. The old Include-mode entry no longer matches. While Proton is connected, Include mode lets every app that is not on the list out through your normal connection. The new executable is one of those apps, so the game uses your real IP even though the VPN is on.

Re-run `Get-RobloxExecutables.ps1` after every Roblox update and replace the paths in Include mode before you play.

Browser traffic to `roblox.com` is a separate path. It follows the browser, not `RobloxPlayerBeta.exe`.
