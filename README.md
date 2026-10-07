# esphome-lvgl-panel

A shared ESPHome + LVGL wall/bedside panel for Home Assistant, styled after
iOS and Android: dark theme, neutral off-white accent, bottom tab bar.

Each display has a short file of its own (name, secrets, which tabs and which
entities). Everything else — layout, styling, behavior — lives in this repo,
so a fix made once reaches every display on its next install.

## Features

- **Status bar** — time, outside temperature + condition, HA connection icon, settings.
- **Lights tab** — scene chips and iOS Control Center-style sliders for lights and fans.
  Rooms with no scenes get the whole tab for sliders.
- **TV tab** — Apple TV remote (d-pad, power, back, home, play/pause, volume pill)
  with now-playing artwork and title.
- **Music tab** — Now Playing for a Music Assistant / media player: artwork,
  title, artist, progress, transport and volume.
- **Favorites tab** — artwork grid that plays playlists or stations.
- **Weather sheet** — tap the weather in the status bar: current conditions,
  humidity/wind/UV, the next 15 hours (every 3 h) and 5 days.
- **Media tabs select themselves** when their player starts playing.
- **Screen care** — dims after 30 s, backlight off after 5 min, wake on touch
  (the waking tap never presses a hidden button) or optional presence; nightly
  anti-burn; brightness setting remembered across reboots.

## Hardware

| Board | File |
|---|---|
| Guition ESP32-S3-4848S040 (480×480, ST7701S + GT911) | `hardware/guition-4848s040.yaml` |

Requires ESPHome 2026.9.0 or newer.

## Quick start (new display)

1. Copy [`examples/display-template.yaml`](examples/display-template.yaml) into
   your HA's `/config/esphome/` and edit the lines marked ◀.
2. Add the secrets it names to `/config/esphome/secrets.yaml`.
   Generate an API key with `head -c 32 /dev/urandom | base64`.
3. For the weather sheet's forecast, copy [`ha/panel_weather.yaml`](ha/panel_weather.yaml)
   into HA's `/config/packages/` (see the file header) and restart HA.
4. Install from the ESPHome dashboard, adopt the device in HA, then in the
   ESPHome integration's options turn on
   **"Allow the device to perform Home Assistant actions."**

## How a display file uses this repo

**From GitHub (other houses)** — one package with a list of files:

```yaml
packages:
  panel:
    url: https://github.com/gjsiii/esphome-lvgl-panel
    ref: v0.1.0
    refresh: 1d
    files:
      - hardware/guition-4848s040.yaml
      - core/core.yaml
      - path: items/light.yaml
        vars: { slot: 1, name: "Ceiling", entity: light.living_room_ceiling }
```

**From a local checkout (development)** — clone into `/config/esphome/panel/`
and include files directly; edits take effect on the next install:

```yaml
packages:
  hardware: !include panel/hardware/guition-4848s040.yaml
  core: !include panel/core/core.yaml
  light_1: !include { file: panel/items/light.yaml, vars: { slot: 1, name: "Ceiling", entity: light.living_room_ceiling } }
```

## Reference

### Required substitutions (device file)

| Name | Meaning |
|---|---|
| `api_key` | HA API encryption key (`!secret`) |
| `wifi_ssid`, `wifi_password` | Wi-Fi (`!secret`) |
| `ap_password` | Fallback hotspot password, 8+ characters (`!secret`) |
| `ha_url` | HA address used for artwork URLs, e.g. `http://192.168.0.10:8123` |

Optional: `ota_password`, `idle_dim_timeout` (30s), `idle_off_timeout` (5min),
`idle_dim_brightness` ("0.30"), `media_autoswitch_gap_ms` ("15000"), and any
palette color from `core/theme.yaml` (`c_bg`, `c_surface`, `c_accent`, …).

### Items (Lights and Favorites tabs)

| File | Vars | Notes |
|---|---|---|
| `items/scene.yaml` | `slot`, `name`, `entity` | Chips, 3 per row; a row of 2 gets wider chips. |
| `items/light.yaml` | `slot`, `name`, `entity` | Brightness slider; sends to HA when released. |
| `items/fan.yaml` | `slot`, `name`, `entity` | Percentage slider; shares slot numbers with lights. |
| `items/favorite.yaml` | `slot`, `name`, `image`, `media_content_id`, `player`, `shuffle` | `image` is relative to the device file and compiled in. Use `shuffle: "false"` for radio. |

`slot` sets the order (1 = first) and must be unique within each kind
(lights and fans share one numbering).

### Tabs

Lights is always tab 1. Other tabs take `tab_position` (2–9) for their order.

| File | Vars |
|---|---|
| `tabs/tv_appletv.yaml` | `tab_position`, `tv_remote`, `tv_player`, `tv_volume_player`, `tv_mute_player` |
| `tabs/music.yaml` | `tab_position`, `music_player` |
| `tabs/favorites.yaml` | `tab_position` |

### Features

| File | Vars | Notes |
|---|---|---|
| `features/weather.yaml` | `weather_entity`, `forecast_entity` | Status-bar weather + weather sheet. Optional substitutions `wind_unit` (mph), `rain_unit` (in). |
| `features/presence_wake.yaml` | `presence_entity` | Wakes a sleeping screen (dimmed) when presence turns on. |

## Updating

1. Make and test changes on a local-checkout display.
2. Update `CHANGELOG.md` and the `version` in `core/base.yaml`, commit, and tag
   (`git tag v0.2.0 && git push --tags`).
3. At each house, change `ref:` to the new tag and choose **Update All** in the
   ESPHome dashboard.

## How it works (for contributors)

ESPHome merges package lists by `id` only at the top level, so a package can't
add widgets inside the shared tab view directly. Instead each tab/item package
builds its widgets on a hidden "holding" page, and an `on_boot` lambda moves
them into place (`lv_tabview_add_tab` + `lv_obj_set_parent`). Boot priorities
order the moves: tabs `-10<tab_position>`, items `-20<slot>`, final layout
`-300` (see `core/base.yaml`).

## License

MIT — see [LICENSE](LICENSE).
