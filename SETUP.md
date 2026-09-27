# Set this up before you play

Roblox is already installed. Leave it installed. These steps only change Proton VPN and the Windows lock that keeps Roblox off your normal internet connection.

Do this on the Windows PC where you already play Roblox. When you are done, the game only works while Proton VPN is connected. If Proton is off, Roblox cannot reach the internet, so it cannot show your real address.

## 1. Sign in to Proton first

1. Open **Proton VPN**.
2. Sign in with the Proton account username and password. A Proton Mail app password will not work in this app.
3. Pick a server and connect.
4. Wait until the app shows you are protected or connected.
5. Disconnect once, so you know where that button is.

Leave Proton open. Do not turn on the kill switch until this connect has worked once.

## 2. Turn on the lock in Proton

1. Open **Settings** (the gear).
2. Open **Split tunneling** and turn it **off**. If it is already off, leave it off.
3. Open **Kill switch**. Turn it on, choose **Advanced**, then click **Apply**. If you are still connected, click **Reconnect** instead.
4. Open **Protocol** and choose **WireGuard UDP**.
5. If you see **Auto-connect** or **Connect on startup**, turn that on.

Advanced kill switch means the whole PC stays offline until Proton is connected, including after a restart. To get internet back, open Proton and connect. If you need the internet without Proton, set Kill switch back to off.

If Windows asks you to sign in with a Microsoft account and the internet is already dead, stop and ask for help before you guess. A sign-in that needs the internet cannot finish while this lock is on.

## 3. Lock the Roblox that is already installed

Quit Roblox if it is open.

1. Open the `roblox-protonvpn` folder.
2. Right-click **Install-Roblox-Lock.cmd**.
3. Click **Run as administrator**.
4. When Windows asks for permission, click **Yes**.

That finds the Roblox programs already on the PC and blocks them on every connection except Proton. You only do this once. After a Roblox update, the PC refreshes the lock by itself.

## 4. Connect, then play

1. In Proton, connect and wait until it says you are protected.
2. Open the Roblox you already have and join a game.

If you open Roblox before Proton is connected, it will fail. Quit Roblox, connect Proton, then open Roblox again.

## 5. Check that it worked

1. With Proton connected, join a game. It should load.
2. Disconnect Proton.
3. The game should drop, and other internet on that PC should stop too.
4. Connect Proton again. Internet and Roblox should work again.

## If something is wrong

- Roblox will not load, and Proton is disconnected: connect Proton, quit Roblox completely, then open Roblox again.
- Roblox will not load, and Proton says connected: quit Roblox, disconnect Proton, connect again, then open Roblox.
- You have no internet at all: open Proton and connect. If Proton will not connect, set Kill switch to off, fix the connection, then turn **Advanced** back on.
- A Windows permission box never appeared in step 3: you did not choose **Run as administrator**. Do that step again.
