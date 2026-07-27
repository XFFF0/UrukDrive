# UrukDrive

Original open-world driving prototype (Godot 4.3) — on-foot movement,
a drivable vehicle with real vehicle physics, a placeholder blocked-out
city, and a minimal "drive to the marker" objective loop. Built as a
starting foundation, not a clone of any existing commercial game.

## Status: early scaffold

What's implemented:
- Third-person on-foot character controller (`scripts/player.gd`)
- Drivable car with `VehicleBody3D` physics (`scripts/vehicle.gd`)
- Enter/exit vehicle interaction (`scripts/world.gd`)
- Orbiting third-person camera (`scripts/camera_rig.gd`)
- Touch joystick + buttons for mobile (`scripts/touch_controls.gd`)
- Simple randomized waypoint objective with HUD distance readout
- GitHub Actions workflow that exports an **unsigned** iOS IPA on a
  macOS runner (`.github/workflows/build-ios.yml`)

What's placeholder / not implemented yet:
- All geometry is primitive `CSGBox3D` / `BoxMesh` blockout — no real
  building, car, or character models/textures
- No NPCs, AI traffic, or pedestrians
- No mission/story system beyond the single waypoint loop
- No sound

## Opening the project

1. Install [Godot 4.3](https://godotengine.org/download) (Standard, not .NET)
2. Open `project.godot` in the Godot editor
3. Press Play — default input is touch-simulated by mouse drag in the
   editor's mobile remote preview, or wire up keyboard `InputMap`
   actions for desktop testing

## Building the IPA

Push to `main` (or trigger manually from the Actions tab) — the
`build-ios` workflow exports and packages an unsigned IPA artifact you
can sideload with your existing tooling. No Apple Developer account or
signing certificate is required since `CODE_SIGNING_ALLOWED=NO`.

## Next steps

- Swap placeholder CSG geometry for real models (Blender exports or
  asset-store kits under a license that permits redistribution)
- Add AI-controlled traffic/pedestrians (`NavigationAgent3D`)
- Expand the mission system beyond a single repeating waypoint
