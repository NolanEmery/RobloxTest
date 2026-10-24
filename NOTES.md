# Rally Rush V1

This workspace did not include `GAME.md` or an existing Roblox place file, so this starter build uses a simple assumption: Rally Rush is a bright, on-foot checkpoint race. Add `GAME.md` later if the intended rules differ.

## Add the scripts in Roblox Studio

Create these two scripts and paste each matching file from `scripts/` in full:

1. **Explorer:** `ServerScriptService` · **Type:** Script · **Name:** `GameServer`
   Source file: `scripts/ServerScriptService/GameServer.server.luau`
2. **Explorer:** `StarterPlayer > StarterPlayerScripts` · **Type:** LocalScript · **Name:** `RallyRushHUD`
   Source file: `scripts/StarterPlayerScripts/RallyRushHUD.client.luau`

The server script creates the course, spawn, checkpoints, boost pads, RemoteEvent, and `leaderstats` (`Wins` and `BestTime`). The HUD is created by the LocalScript. No Toolbox models or plugins are needed.

## Try it

1. Open your place in Roblox Studio and add the two scripts above.
2. Press **Play** (F5). Your character should spawn on the blue platform.
3. Walk across the start line, run through the four green checkpoints in order, and cross the finish arch.
4. Touch a pink pad for a short speed boost. Check `Wins` and `BestTime` in the player list, then try again.

If you fall or reset, start again from the blue platform. The current version keeps scores only for the current play session; it does not save them between sessions.

## Publishing and save point

No Roblox place file was available in this workspace, and this build has not been pasted into Studio or published. The place's published status and destination are therefore unknown. In Studio, use **File > Save to Roblox** to update your existing published place, or **File > Publish to Roblox As...** to choose a destination. Do not overwrite a different place by mistake.

The `RallyRush_V1_SavePoint.zip` file is a save point of the scripts and notes prepared here. Save your Roblox place separately in Studio after pasting the scripts.
