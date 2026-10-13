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
    ref: v0.5.0
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
| One hardware file (below) | The board: display, touch, backlight, flash, PSRAM. |
| `core/core.yaml` | Everything shared: theme, status bar, Lights tab, settings, screen care, messages, About. |

### Hardware

| File | Board |
|---|---|
| `hardware/guition-4848s040.yaml` | Guition ESP32-S3-4848S040: 4″ 480×480, relays, 16 MB flash. |
| `hardware/waveshare-esp32-p4-86-4b.yaml` | Waveshare ESP32-P4-WIFI6-Touch-LCD-4B: 4″ 720×720, Wi-Fi 6, speaker and microphones (for [voice](features.md#voice)), 32 MB flash. |

The screens are designed once and scaled to each board, so a 720×720 panel
looks the same as a 480×480 one, only sharper.

**Waveshare P4 settings** (substitutions, defaults shown):

| Name | Default | Meaning |
|---|---|---|
| `p4_engineering_sample` | `false` | `true` (no quotes) for early boards with a pre-production chip: the boot log shows `esp32p4-eco2` or a chip revision below v3.0. A build for the wrong chip revision won't boot. |
| `p4_cpu_frequency` | `360MHz` | `400MHz` works on production chips but is still experimental in ESPHome. |
| `p4_psram_speed` | `200MHz` | Try `100MHz` if a flickering band appears at one edge of the screen. |
| `dsi_pclk` | `30MHz` | Display pixel clock (about 48 frames per second). Lower it (e.g. `28MHz`) if a faint band remains. |
| `lvgl_rotation` | `"0"` | `"0"`, `"90"`, `"180"` or `"270"`, to match how the panel is mounted. |

## Substitutions

Set in the display file's `substitutions:`.

**Required**

| Name | Example | Meaning |
|---|---|---|
| `api_key` | `!secret …_api_key` | Home Assistant API encryption key (32 random bytes, base64). It also encrypts and authenticates over-the-air updates. |
| `wifi_ssid`, `wifi_password` | `!secret wifi_ssid` | Wi-Fi. |
| `ap_password` | `!secret …_ap_password` | Password of the fallback hotspot the panel opens if Wi-Fi fails (8+ characters). |
| `ha_url` | `"http://192.168.1.10:8123"` | Home Assistant address, used to load album art, TV art and camera snapshots. |

**Optional** (defaults shown)

| Name | Default | Meaning |
|---|---|---|
| `default_dim_after` | `"30 s"` | First-boot value of *Dim after* (15 s, 30 s, 1 min, 2 min, Never). |
| `default_off_after` | `"5 min"` | First-boot value of *Turn off after* (1 min, 5 min, 10 min, 30 min, Never). |
| `default_sleep_screen` | `"Blank"` | First-boot value of *Sleep screen* (Blank, Clock, Red clock). |
| `idle_dim_brightness` | `"0.30"` | Dim level. |
| `night_clock_brightness` | `"0.25"` | Backlight behind the night clock. The backlight is gamma-corrected: below about 0.15 the LEDs barely light. |
| `media_autoswitch_gap_ms` | `"15000"` | A media tab only opens itself if playback starts after being stopped this long (ignores the gap between tracks). |
| `lights_title` | `"LIGHTS"` | Heading above the sliders on the Lights tab, e.g. `"LIGHTS & SHADES"`. |
| `update_entity` | `sensor.esphome_lvgl_panel_latest` | HA sensor with the newest released version, for the update notice (`ha/panel_updates.yaml`). |
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
| `tabs/ma_favorites.yaml` | `tab_position`, `music_player`, `ma_url`, optional `favorites_entity` (default `sensor.panel_ma_favorites`) | Live Music Assistant favorites with category chips. Needs `ha/panel_ma_favorites.yaml` (same release). Any board; artwork is kept in PSRAM. See [Favorites from Music Assistant](features.md#favorites-from-music-assistant). |
| `tabs/timer.yaml` | `tab_position`, optional `preset_1` … `preset_6` (minutes; default 1, 3, 5, 10, 15, 30) | Preset, custom and voice timers. Needs `features/voice_assistant.yaml`. See [Timer tab](features.md#timer-tab). |

## Items

Items are repeated: include one per light, scene, app, speaker or favorite.
`slot` sets the order (1 = first) and must be unique within its group.

| File | Vars | Group | Notes |
|---|---|---|---|
| `items/scene.yaml` | `slot`, `name`, `entity` | scene chips | `scene.turn_on`. |
| `items/action_chip.yaml` | `slot`, `name`, `action`, `entity` | scene chips | Any HA action, e.g. `light.turn_off`, `scene.turn_on` or `script.turn_on`. `entity` may be a comma-separated list (e.g. an HA scene plus a Hue scene). |
| `items/light.yaml` | `slot`, `name`, `entity` | sliders | Brightness slider; tap the name to toggle, hold it for the color sheet. |
| `items/fan.yaml` | `slot`, `name`, `entity` | sliders | Fan speed (percentage) slider. |
| `items/cover.yaml` | `slot`, `name`, `entity` | sliders | Shade / blind / curtain position slider; tap the name to open, close or stop. |
| `items/tv_app.yaml` | `slot`, `icon`, `source`, `entity` | TV apps | `icon`: path to an image relative to the display file; `source`: the Apple TV source name. |
| `items/speaker.yaml` | `slot`, `name`, `entity`, `leader` | Play on | `leader` is this room's `music_player`. A grouped speaker shows its own volume slider. |
| `items/favorite.yaml` | `slot`, `name`, `image`, `media_content_id`, `player`, `shuffle` | favorites | `image` relative to the display file; `shuffle: "true"` / `"false"`. |

## Features

Each feature is included at most once, except camera pop-ups and status chips.

| File | Vars | |
|---|---|---|
| `features/weather.yaml` | `weather_entity`, `forecast_entity`, optional `outdoor_temp_entity` | Status-bar weather and the weather sheet. Needs `ha/panel_weather.yaml` for the forecast. |
| `features/climate.yaml` | `climate_entity`, `climate_name` | Indoor temperature and the thermostat sheet. |
| `features/status_chip.yaml` | `chip_id`, `slot`, `entity`, `icon`, `color`, `show_when`, `show_value` | One per status icon. See [Status icons](features.md#status-icons-chips). |
| `features/marine.yaml` | `marine_entity`, `title`, `open_chip_1`, `open_chip_2` | Full-text forecast sheet opened from status chips. |
| `features/snow_report.yaml` | `title`, `chip_slot`, `chip_show`, `new_24h_entity`, `new_48h_entity`, `new_72h_entity`, `new_7d_entity`, `base_entity`, `summit_entity`, `season_entity`, `lifts_entity`, `runs_entity`, `opening_entity`; optional `powder_inches` (default `"3"`) | Snowflake chip (24 h new snow), the ski report sheet and the powder-day sleep note. See [Snow report](features.md#snow-report). |
| `features/camera_popup.yaml` | `popup_id`, `title`, `trigger_entity`, `camera_entity` | One per trigger. |
| `features/presence_wake.yaml` | `presence_entity` | Wake on presence. |
| `features/sleep_notes.yaml` | optional `note_entity` (default `sensor.panel_night_note`) | Sleep message and birthdays on the night clock. Needs `ha/panel_notes.yaml`. See [Sleep screen notes](features.md#sleep-screen-notes). |
| `features/holidays.yaml` | optional `decorations` (default `8`) | Holiday themes, off until the panel's **Holiday Theme** switch is turned on in HA. See [Holiday themes](features.md#holiday-themes). |
| `features/voice_assistant.yaml` | — | Wake word and Home Assistant Assist, with a mic button in the status bar. Needs a board with a speaker and microphones (Waveshare P4). See [Voice](features.md#voice). |

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
    ref: v0.5.0
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
