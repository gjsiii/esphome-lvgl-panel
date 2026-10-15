# Home Assistant side

## Packages to install

Copy these from [`ha/`](../ha/) into Home Assistant's `/config/packages/`
(enable packages with `homeassistant: packages: !include_dir_named packages`
in `configuration.yaml`), then restart Home Assistant.

| File | Adds | Needed for |
|---|---|---|
| `panel_weather.yaml` | `sensor.panel_weather_forecast` — state: time of the last update; attributes `hourly` and `daily` (compact text the panels read). Refreshed every 30 minutes with `weather.get_forecasts`. | The weather sheet's forecast. Change `source:` to your weather entity. |
| `panel_messages.yaml` | `script.panel_message` | Sending banners to several panels with optional fields. |
| `panel_updates.yaml` | `sensor.esphome_lvgl_panel_latest` — the newest released version (from GitHub tags, every 6 hours). | The update notice in Settings. Optional. |
| `panel_notes.yaml` | `input_text.panel_sleep_message`, `sensor.panel_night_note` (the night clock note: a sleep message, or the next birthday within a week, from Date helpers named `Birthday: …`), and the *Panel reminders* automation (banners when a Schedule helper named `Reminder: …` starts a time block). | `features/sleep_notes.yaml` and reminders. Edit the `panels:` list in the automation. Needs `panel_messages.yaml` for reminders. |
| `panel_marine.yaml` | `sensor.panel_marine` — state: `hazard`, `upcoming` or `clear`; attributes `hazard_text`, `upcoming_text`, `event` (e.g. Small Craft Advisory), `short` (SCA, Gale, Storm… for small dashboard badges), `period_1..5`, `forecast_1..5`. Built from the [NOAA It All](https://github.com/dawg-io/noaa_it_all) integration's marine Forecast and Hazard sensors. | `features/marine.yaml`. Replace `lmz741` with your marine zone (4 places). |
| `panel_ma_favorites.yaml` | `sensor.panel_ma_favorites` — state: number of favorites; attribute `items` (compact list the panels read). Re-read every 15 minutes with `music_assistant.get_library`, and when a panel's refresh button is tapped. | `tabs/ma_favorites.yaml`. Set `ma_entry` to your Music Assistant config entry id (the entry picker in Developer Tools → Actions → `music_assistant.get_library` shows it). |

One forecast sensor serves every panel in the house, and one favorites sensor
every panel with the Music Assistant favorites tab.

The favorites list is too long for the history database; keep it out:

```yaml
recorder:
  exclude:
    entities:
      - sensor.panel_ma_favorites
```

Artwork links from Apple Music and Spotify are rewritten to ask for ~300 px
images, which the panel decodes much faster than the 640–1000 px originals.

## Permission to control things

Panels send their button presses to Home Assistant as actions. For each panel:
**Settings → Devices & services → ESPHome → (panel) → Configure → "Allow the
device to perform Home Assistant actions."** Until this is on, HA logs
"Service call … rejected" and buttons do nothing.

## Entities each panel adds

On the panel's device page:

**Configuration** (settings — change them here or on the panel)

| Entity | Type | |
|---|---|---|
| Slider Color | light (RGB) | Color wheel + brightness for the slider color; off = default. |
| Slider Text Color | select | Auto / Light / Dark. |
| Dim After, Turn Off After | select | Screen timing. |
| Sleep Screen | select | Blank / Clock / Red clock. |
| Night Mode | switch | Night schedule on/off. |
| Night Starts, Night Ends, Night Brightness | select | Night schedule. |
| 24-Hour Clock | switch | |
| Auto-Open TV & Music | switch | |
| Messages Wake at Full Brightness | switch | |
| Settings PIN Lock | switch | |
| Settings PIN | text (hidden) | Clear it to remove the PIN. |
| Antiburn | switch | Runs the anti-burn "snow" now. |
| Holiday Theme | switch | Panels with `features/holidays.yaml`: holiday colours and night clock decorations by date. Off by default. |
| Holiday Preview | select | Disabled until you enable it: shows one holiday's theme now (By date / Halloween / Christmas / Valentine's Day / St. Patrick's Day). |
| Restart | button | |

**Controls / Diagnostic**

| Entity | |
|---|---|
| Backlight | The panel's backlight as a light. |
| IP Address, Wi-Fi Signal, Uptime, Reset Reason | Diagnostics. *Reset Reason* tells you why the panel last restarted (power loss, brown-out, crash). |
| Relay 1–3 | The board's three relays (Guition board, if wired). |

## Voice

Panels with [`features/voice_assistant.yaml`](../features/voice_assistant.yaml)
also add:

| Entity | Type | |
|---|---|---|
| Assist satellite | assist_satellite | The panel as a voice satellite: target it for announcements (`assist_satellite.announce`) or to start a conversation (`assist_satellite.start_conversation`). |
| Assistant, Finished Speaking Detection | select | Which Assist pipeline the panel uses, and how quickly it decides you've stopped talking. |
| Wake Word | select | Okay Nabu or Hey Jarvis. |
| Mute Wake Word | switch | Same as the mic icon on the panel. |
| Panel Speaker | media_player | The panel's built-in speaker: replies, announcements and anything you play to it. |

Set up Assist under **Settings → Voice assistants** (speech-to-text,
text-to-speech, conversation agent) before the first try. The "Allow the
device to perform Home Assistant actions" option above is needed for voice
too.

## Messages

Every panel offers two actions (the panel's name with `-` replaced by `_`):

| Action | Fields |
|---|---|
| `esphome.<panel>_show_message` | `title`, `message`, `icon`, `seconds` — all required. |
| `esphome.<panel>_clear_message` | — |

`script.panel_message` (from `panel_messages.yaml`) adds defaults and can
target several panels:

| Field | Default | |
|---|---|---|
| `panels` | — | Panel device names, e.g. `[esp-family-room-480x480, esp-kitchen-panel]`. |
| `title` | — | First line, bold. |
| `message` | `""` | Up to two lines. |
| `icon` | `info` | `info`, `alert`, `bell`, `door`, `gate`, `mail`, `washer`, `car`, `check`. |
| `seconds` | `15` | `0` keeps it until tapped. |

A message wakes a sleeping panel (to the dim level, or to full brightness with
*Messages Wake at Full Brightness*). A new message replaces the current one;
tap the banner to dismiss it.

### Examples

**Laundry done** (washer power drops):

```yaml
triggers:
  - trigger: numeric_state
    entity_id: sensor.washer_power
    below: 5
    for: "00:02:00"
actions:
  - action: script.panel_message
    data:
      panels: [esp-family-room-480x480, esp-kitchen-panel]
      title: Washer done
      message: Time to move the laundry to the dryer.
      icon: washer
      seconds: 0
```

**Garage left open** (and clear the banner when it closes):

```yaml
triggers:
  - trigger: state
    entity_id: cover.garage_door
    to: open
    for: "00:15:00"
    id: open
  - trigger: state
    entity_id: cover.garage_door
    to: closed
    id: closed
actions:
  - choose:
      - conditions: [{ condition: trigger, id: open }]
        sequence:
          - action: script.panel_message
            data: { panels: [esp-family-room-480x480], title: Garage still open, icon: car, seconds: 0 }
      - conditions: [{ condition: trigger, id: closed }]
        sequence:
          - action: esphome.esp_family_room_480x480_clear_message
```

## Automating the panel's settings

Because the settings are ordinary entities, automations can change them:

**Lock kids' panels at bedtime:**

```yaml
triggers:
  - trigger: time
    at: "20:00:00"
actions:
  - action: switch.turn_on
    target: { entity_id: switch.girls_bedroom_480x480_settings_pin_lock }
```

**Match the slider color to the season** (green in spring):

```yaml
actions:
  - action: light.turn_on
    target: { entity_id: light.family_room_480x480_slider_color }
    data: { rgb_color: [48, 209, 88], brightness_pct: 100 }
```

(Entity IDs depend on each panel's name — check its device page.)

## Room scenes with several lighting systems

A room often mixes systems, for example Hue bulbs with Hue scenes plus Lutron
dimmers. You don't need a script: make an ordinary HA scene for the other
lights and turn it on **together with** the Hue scene. An `action_chip`
accepts a comma-separated list of entities:

```yaml
# scenes.yaml (or Settings → Scenes)
- id: bedroom_relax_lutron
  name: Bedroom Relax (Lutron)
  entities:
    light.bedroom_ceiling: { state: 'on', brightness: 64 }   # 25%
    light.bedroom_lamp: { state: 'on', brightness: 140 }     # 55%
```

```yaml
# display file
- path: items/action_chip.yaml
  vars: { slot: 1, name: "Relax", action: scene.turn_on, entity: "scene.bedroom_relax_lutron, scene.bedroom_relax" }
```

An "Off" chip can be a single HA scene that turns every light in the room off.
Use a script instead only when the steps must happen in order or wait for
something.

**Lights that follow another light.** If an automation makes some lights
mirror another (say Hue lamps follow a Lutron lamp's wall dimmer or Pico),
it will repaint the Hue scene a moment after the chip changes the Lutron
lamp. Skip the automation for a few seconds after your scenes. A scene's
state is the time it was last turned on:

```yaml
condition:
  - condition: template
    value_template: >-
      {{ expand('scene.bedroom_relax_lutron', 'scene.bedroom_off')
         | map(attribute='state') | map('as_datetime', none) | reject('none')
         | select('gt', now() - timedelta(seconds=10)) | list | count == 0 }}
```

**Smart bulbs behind a dimmer?** Keep them powered all the time: replace the
dimmer with a plain switch you leave on (or wire the bulbs straight through),
and control the bulbs instead. Group them in their own app (for Hue, a room
or zone such as `light.east_table_lamps`) and use that group for the slider.
Hue groups support warmth and color, so holding the name opens the full
[color sheet](features.md#light-color-sheet). Bulbs whose power is cut drop
off the network, so the panel can't turn them back on.
