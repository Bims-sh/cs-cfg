# cs-cfg

CS2 config for Linux on Wayland.

## Launch args

```
SDL_VIDEODRIVER=wayland gamemoderun taskset -c 0-11 %command% -nojoy -novid -console +exec autoexec +fps_max 0 +engine_low_latency_sleep_after_client_tick 1
```

| Arg                                             | Why                                                              |
|-------------------------------------------------|------------------------------------------------------------------|
| `SDL_VIDEODRIVER=wayland`                       | Native Wayland, skips the XWayland latency hop                   |
| `gamemoderun`                                   | Performance governor, renices the game                           |
| `taskset -c 0-11`                               | The 13600K's P-core threads, keeps the render thread off E-cores |
| `-nojoy`                                        | Skips the joystick subsystem                                     |
| `-novid`                                        | Skips the intro                                                  |
| `-console`                                      | Console open on launch                                           |
| `+exec autoexec`                                | Loads this config                                                |
| `+fps_max 0`                                    | Uncapped, correct with tearing on and VRR off                    |
| `+engine_low_latency_sleep_after_client_tick 1` | No-op unless Reflex is enabled                                   |

## Hardware

| Type     | Name                                 |
|----------|--------------------------------------|
| Keyboard | Wooting 60HE v2                      |
| Mouse    | Zowie EC2-CW                         |
| Monitor  | Gigabyte MO27Q28G, 1440p 280 Hz OLED |
| GPU      | RTX 4070                             |
| CPU      | i5-13600K                            |

**Wooting Profile**: `ab3f67ca2dcc1e4f4be76880d0a1980185b8`

## Settings

| Setting | Value |
|---------|-------|
| DPI     | 400   |
| Sens    | 2.125 |
| eDPI    | 850   |
| `m_yaw` | 0.022 |

## Video Settings

| Setting                          | Value               |
|----------------------------------|---------------------|
| Display Mode                     | Fullscreen Windowed |
| Resolution                       | 1920x1440           |
| Boost Player Contrast            | Enabled             |
| Wait for Vertical Sync           | Disabled            |
| NVIDIA Reflex Low Latency        | Enabled + Boost     |
| Maximum FPS In Game              | 0                   |
| Multisampling Anti-Aliasing Mode | 2x MSAA             |
| Global Shadow Quality            | Low                 |
| Dynamic Shadows                  | All                 |
| Model / Texture Detail           | Low                 |
| Texture Filtering Mode           | Anisotropic 4X      |
| Shader Detail                    | Low                 |
| Particle Detail                  | Low                 |
| Ambient Occlusion                | Disabled            |
| High Dynamic Range               | Performance         |
| FidelityFX Super Resolution      | Disabled            |

## Hyprland / Wayland

### Native Wayland

Check that the game runs as a native Wayland client rather than through XWayland.

```bash
hyprctl clients -j | jq -r '.[]|select(.class|test("cs2";"i"))|"xwayland=\(.xwayland)"'
```

The launch arg is not enough alone. `game/cs2.sh` ships `x11` and is patched:

```bash
if [ -z "$SDL_VIDEO_DRIVER" ]; then
	export SDL_VIDEO_DRIVER=wayland
fi
```

- **Breaks the Steam overlay.** Shift+Tab, screenshots, friends list, overlay browser.
  The overlay hooks GLX but not EGL, and X11 Vulkan surfaces but not Wayland ones, so it
  cannot attach to a native Wayland client. Still open:
  [ValveSoftware/steam-for-linux#8020](https://github.com/ValveSoftware/steam-for-linux/issues/8020).
  The `x11` default this patch removes is Valve's workaround for that bug.
- Steam restores `cs2.sh` on game update or file validation.
- Script reads `SDL_VIDEO_DRIVER` (SDL3), launch arg sets `SDL_VIDEODRIVER` (SDL2).
  Either works.

### Compositor

```lua
hl.config({
    general = {
        allow_tearing = true
    },
    render = {
        direct_scanout = 2,
        cm_enabled = false
    },
    misc = {
        vrr = 0,
        vfr = true
    }
})
```

| Setting              | Effect                                                     |
|----------------------|------------------------------------------------------------|
| `allow_tearing`      | Required before any `immediate` window rule does anything  |
| `direct_scanout`     | Lets a fullscreen surface go straight to the display plane |
| `cm_enabled = false` | Removes a full-screen color conversion pass                |
| `vrr = 0`            | VRR does nothing above max refresh                         |
| `vfr = true`         | Idle outputs stop redrawing                                |

### Color management

Off. Every monitor is on an sRGB preset and nothing uses HDR, so the pipeline was
converting sRGB into sRGB: a no-op full-screen shader pass per frame per monitor,
costing 10 to 35 percent of the GPU.

```bash
hyprctl monitors -j | jq -r '.[]|"\(.name) preset=\(.colorManagementPreset) sdrMax=\(.sdrMaxLuminance)"'
```

Wide-gamut panels go unclamped and look oversaturated. That belongs in the monitor's
OSD.

### Window rules

```lua
local cs2 = { initial_class = "^(.*cs2.*)$" }

hl.window_rule({ match = cs2, immediate = true })
hl.window_rule({ match = cs2, fullscreen = true })
hl.window_rule({ match = cs2, opacity = 1 })
hl.window_rule({ match = cs2, decorate = 0 })
hl.window_rule({ match = cs2, no_shadow = 1 })
hl.window_rule({ match = cs2, no_dim = 1 })
hl.window_rule({ match = cs2, rounding = 0 })
hl.window_rule({ match = cs2, idle_inhibit = "focus" })
```

| Rule           | Effect                                         |
|----------------|------------------------------------------------|
| `immediate`    | Tearing for this window, needs `allow_tearing` |
| `fullscreen`   | Lets the window become the solitary surface    |
| `opacity = 1`  | Fully opaque, skips alpha blending             |
| `decorate = 0` | No decorations to draw                         |
| `no_shadow`    | Skips the shadow pass                          |
| `no_dim`       | Skips the dim pass                             |
| `rounding = 0` | Skips the rounded-corner mask                  |
| `idle_inhibit` | No idle or DPMS mid-game                       |

Matched on the **native** app id `cs2`. Under XWayland it is `steam_app_730`, and rules
written only for that silently do nothing once the game goes native.

### VRR

Off. Nothing to adapt to above max refresh, and engaging it needs a cap below refresh.

### Other monitors

Windows on a second output make the compositor composite it at that output's refresh
rate, and those bursts land inside the game's frame. Shows as frametime spikes rather
than lower average fps.
