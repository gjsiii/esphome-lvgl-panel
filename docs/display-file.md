# Display file reference

A display file is a short ESPHome YAML file — one per panel — that names the
panel, holds its secrets, and lists which shared files (and with which
entities) make up that panel. Start from
[`examples/display-template.yaml`](../examples/display-template.yaml).

## Anatomy

```yaml
substitutions:                 # 1. settings for this panel
  api_key: !secret living_room_panel_api_key
  wifi_ssid: !secret wifi_ssid
  wifi_password: !secret wifi_password
  ap_password: !secret living_room_panel_ap_password
  ha_url: "http://192.168.1.10:8123"

esphome:                       # 2. the panel's identity
  name: esp-living-room-panel
  friendly_name: Living Room Panel

packages:                      # 3. the shared files it's built from
  panel:
    url: https://github.com/gjsiii/esphome-lvgl-panel
    ref: v0.2.0
    refresh: 1d
    files:
      - hardware/guition-4848s040.yaml      # always
      - core/core.yaml                      # always
      - path: items/light.yaml              # one entry per item, with its vars
        vars: { slot: 1, name: "Ceiling", entity: light.living_room_ceiling }
```

- **Plain entries** (`- core/core.yaml`) are files that take no settings.
- **`path:` + `vars:` entries** are files that take settings. The same file can
  appear many times with different `vars` (one per light, speaker, favorite…).
- **Local form** — if the repository is cloned into `/config/esphome/panel/`:
  `light_1: !include { file: panel/items/light.yaml, vars: { … } }`. Same
  files, same vars.
- **Order doesn't matter** in the list; `slot` and `tab_position` decide the
  order on screen.

## Required

| File | Purpose |
|---|---|
| `hardware/guition-4848s040.yaml` | Display, touch, backlight, relays, 16 MB flash, PSRAM. |
| `core/core.yaml` | Everything shared: theme, status bar, Lights tab, settings, screen care, messages, About. |

## Substitutions

Set in the display file's `substitutions:`.

**Required**

| Name | Example | Meaning |
|---|---|---|
| `api_key` | `!secret …_api_key` | Home Assistant API encryption key (32 random bytes, base64). |
| `wifi_ssid`, `wifi_password` | `!secret wifi_ssid` | Wi-Fi. |
| `ap_password` | `!secret …_ap_password` | Password of the fallback hotspot the panel opens if Wi-Fi fails (8+ characters). |
| `ha_url` | `"http://192.168.1.10:8123"` | Home Assistant address, used to load album art, TV art and camera snapshots. |

**Optional** (defaults shown)

| Name | Default | Meaning |
|---|---|---|
| `ota_password` | `""` | Password for over-the-air updates. |
| `default_dim_after` | `"30 s"` | First-boot value of *Dim after* (15 s, 30 s, 1 min, 2 min, Never). |
| `default_off_after` | `"5 min"` | First-boot value of *Turn off after* (1 min, 5 min, 10 min, 30 min, Never). |
| `default_sleep_screen` | `"Blank"` | First-boot value of *Sleep screen* (Blank, Clock, Red clock). |
| `idle_dim_brightness` | `"0.30"` | Dim level. |
| `night_clock_brightness` | `"0.25"` | Backlight behind the night clock. The backlight is gamma-corrected: below about 0.15 the LEDs barely light. |
| `media_autoswitch_gap_ms` | `"15000"` | A media tab only opens itself if playback starts after being stopped this long (ignores the gap between tracks). |
| `camera_popup_seconds`, `camera_refresh_seconds` | `"60"`, `"5"` | Camera pop-up duration and refresh interval. |
| `climate_min`, `climate_max` | `"50"`, `"90"` | Thermostat dial range. |
| `wind_unit`, `rain_unit` | `mph`, `in` | Units shown on the weather sheet. |
| `c_bg`, `c_surface`, `c_surface_2`, `c_separator`, `c_text`, `c_text_2`, `c_accent`, `c_on_accent`, `c_selected` | see `core/theme.yaml` | Theme colors (`"0xRRGGBB"`). |

The *default_* values only apply until the setting is changed on the panel or
in Home Assistant; after that the saved value wins.

## Tabs

Lights is always the first tab. Other tabs take `tab_position` (2–9), which
orders the tab bar. Leave a tab out and it simply isn't there.

| File | Vars | |
|---|---|---|
| `tabs/tv_appletv.yaml` | `tab_position`, `tv_remote`, `tv_player`, `tv_volume_player`, `tv_mute_player` | Apple TV remote. `tv_volume_player` and `tv_mute_player` can be the Apple TV itself, a soundbar or the TV. |
| `tabs/music.yaml` | `tab_position`, `music_player` | Now Playing for one speaker (a Music Assistant player works best). |
| `tabs/favorites.yaml` | `tab_position` | Grid for `items/favorite.yaml`. |

## Items

Items are repeated: include one per light, scene, app, speaker or favorite.
`slot` sets the order (1 = first) and must be unique within its group.

| File | Vars | Group | Notes |
|---|---|---|---|
| `items/scene.yaml` | `slot`, `name`, `entity` | scene chips | `scene.turn_on`. |
| `items/action_chip.yaml` | `slot`, `name`, `action`, `entity` | scene chips | Any HA action, e.g. `light.turn_off` or `script.turn_on`. `entity` may be a comma-separated list. |
| `items/light.yaml` | `slot`, `name`, `entity` | sliders | Brightness slider; tap the name to toggle. |
| `items/fan.yaml` | `slot`, `name`, `entity` | sliders | Fan speed (percentage) slider. |
| `items/tv_app.yaml` | `slot`, `icon`, `source`, `entity` | TV apps | `icon`: path to an image relative to the display file; `source`: the Apple TV source name. |
| `items/speaker.yaml` | `slot`, `name`, `entity`, `leader` | Play on | `leader` is this room's `music_player`. |
| `items/favorite.yaml` | `slot`, `name`, `image`, `media_content_id`, `player`, `shuffle` | favorites | `image` relative to the display file; `shuffle: "true"` / `"false"`. |

## Features

Each feature is included at most once, except camera pop-ups and status chips.

| File | Vars | |
|---|---|---|
| `features/weather.yaml` | `weather_entity`, `forecast_entity`, optional `outdoor_temp_entity` | Status-bar weather and the weather sheet. Needs `ha/panel_weather.yaml` for the forecast. |
| `features/climate.yaml` | `climate_entity`, `climate_name` | Indoor temperature and the thermostat sheet. |
| `features/status_chip.yaml` | `chip_id`, `slot`, `entity`, `icon`, `color`, `show_when`, `show_value` | One per status icon. See [Status icons](features.md#status-icons-chips). |
| `features/marine.yaml` | `marine_entity`, `title`, `open_chip_1`, `open_chip_2` | Full-text forecast sheet opened from status chips. |
| `features/camera_popup.yaml` | `popup_id`, `title`, `trigger_entity`, `camera_entity` | One per trigger. |
| `features/presence_wake.yaml` | `presence_entity` | Wake on presence. |

## Values and quoting

- **Text with spaces or punctuation** — quote it: `name: "Movie Lights"`.
- **Booleans for `shuffle` / `show_value`** — quote them: `"true"`, `"false"`.
- **Icons** — `"\U000F06DA"` (double quotes are required for the escape).
- **Colors** — `"0xRRGGBB"`.
- **Image paths** are relative to the display file, e.g.
  `../www/playlist_icons/jazz.png` for `/config/www/playlist_icons/jazz.png`.

## A complete example

```yaml
substitutions:
  api_key: !secret bedroom_panel_api_key
  wifi_ssid: !secret wifi_ssid
  wifi_password: !secret wifi_password
  ap_password: !secret bedroom_panel_ap_password
  ha_url: "http://192.168.1.10:8123"

esphome:
  name: esp-bedroom-panel
  friendly_name: Bedroom Panel

packages:
  panel:
    url: https://github.com/gjsiii/esphome-lvgl-panel
    ref: v0.2.0
    refresh: 1d
    files:
      - hardware/guition-4848s040.yaml
      - core/core.yaml
      - path: features/weather.yaml
        vars: { weather_entity: weather.home, forecast_entity: sensor.panel_weather_forecast }
      - path: features/climate.yaml
        vars: { climate_entity: climate.upstairs, climate_name: "Upstairs" }
      # Lights tab (no scenes: the sliders get the whole tab)
      - path: items/light.yaml
        vars: { slot: 1, name: "Ceiling", entity: light.bedroom_ceiling }
      - path: items/light.yaml
        vars: { slot: 2, name: "Bedside", entity: light.bedside_lamp }
      - path: items/fan.yaml
        vars: { slot: 3, name: "Fan", entity: fan.bedroom }
      # Music with one extra speaker
      - path: tabs/music.yaml
        vars: { tab_position: 2, music_player: media_player.bedroom }
      - path: items/speaker.yaml
        vars: { slot: 1, name: "Bathroom", entity: media_player.bathroom, leader: media_player.bedroom }
```
