# Using the panel

Each section shows what a feature does on the panel and the lines that turn it
on in a display file. Display file snippets use the GitHub form (an entry in
the `files:` list); see [Display file reference](display-file.md) for the
local `!include` form and every option.

- [The status bar](#the-status-bar)
- [Lights tab](#lights-tab)
- [TV tab](#tv-tab)
- [Music tab and Play on](#music-tab-and-play-on)
- [Favorites tab](#favorites-tab)
- [Weather](#weather)
- [Climate](#climate)
- [Status icons (chips)](#status-icons-chips)
- [Marine forecast](#marine-forecast)
- [Camera pop-ups](#camera-pop-ups)
- [Messages from Home Assistant](#messages-from-home-assistant)
- [Settings](#settings)
- [Screen dimming, sleep and the night clock](#screen-dimming-sleep-and-the-night-clock)
- [Night mode](#night-mode)
- [PIN lock](#pin-lock)
- [About and restart](#about-and-restart)

---

## The status bar

Left to right: **outside weather** (tap for the forecast), **indoor
temperature** (tap for the thermostat), the **time**, **status icons**, the
**connection icon** and the **gear** (Settings).

- The connection icon is grey while Home Assistant is connected and turns
  **red (Wi-Fi off)** when HA isn't. Buttons don't work while it's red.
- Weather, climate and status icons only appear if the display file includes
  them.

## Lights tab

![Lights tab](images/lights.svg)

Always the first tab.

**Scenes** — a row of pill buttons (three per row; a final row of two gets
wider buttons). Rooms without scenes hide the SCENES section and give the
sliders the whole tab.

**Lights and fans** — Control Center-style sliders.

- **Drag** anywhere to set brightness (or fan speed); Home Assistant is updated
  once, when you lift your finger.
- **Tap the name** to toggle the light on/off.
- The percentage follows changes made anywhere else (wall switch, app, HA).
- Fans show **Off** at 0; fans with fixed speeds (e.g. Lutron 25/50/75/100)
  snap to the nearest speed.
- Three sliders fit; more scroll.

```yaml
- path: items/scene.yaml
  vars: { slot: 1, name: "Evening", entity: scene.living_room_evening }
- path: items/action_chip.yaml            # a chip that runs any HA action
  vars: { slot: 2, name: "Off", action: light.turn_off, entity: "light.lamp, light.ceiling" }
- path: items/light.yaml
  vars: { slot: 1, name: "Ceiling", entity: light.living_room_ceiling }
- path: items/fan.yaml
  vars: { slot: 2, name: "Fan", entity: fan.living_room }
```

`slot` sets the order. Scene chips and action chips share one numbering;
lights and fans share another.

> **Tip — scenes that span several systems.** If a scene only covers some of
> a room's lights (for example Hue scenes and Lutron dimmers), write an HA
> script that sets the other lights and then activates the scene, and point an
> `action_chip` at it with `action: script.turn_on`.

## TV tab

![TV tab](images/tv.svg)

Modeled on the iOS Remote app, for an Apple TV.

- **D-pad** — swipe-free arrows and a center select button.
- **Power** (tap: wake the Apple TV; hold: sleep), **Back**, **Home**,
  **Play/Pause**.
- **Skip back / forward** either side of the volume pill.
- **Volume − / mute / +** — can control a different device than the Apple TV
  (for example a Sonos soundbar), and mute can target yet another (the TV).
- **Now playing** (top left, only while playing or paused) — the show's
  artwork, name and app.
- **App buttons** (right of the d-pad, optional) — tap to open the app on the
  Apple TV.

```yaml
- path: tabs/tv_appletv.yaml
  vars:
    tab_position: 2
    tv_remote: remote.living_room_apple_tv
    tv_player: media_player.living_room_apple_tv
    tv_volume_player: media_player.living_room_sonos   # what − / + control
    tv_mute_player: media_player.living_room_sonos     # what mute controls
- path: items/tv_app.yaml
  vars:
    slot: 1
    icon: ../www/tv_app_icons/netflix.svg   # your own image, next to the display file
    source: "Netflix"                       # exactly as in the Apple TV's source list
    entity: media_player.living_room_apple_tv
```

**App icons.** Logos are trademarks, so this repository doesn't ship them. Put
a square image per app (PNG, JPG or SVG; a white logo on a transparent
background matches the remote) somewhere under `/config/www/` and point `icon`
at it, relative to the display file. One source of single-color brand SVGs is
the [custom-brand-icons](https://github.com/elax46/custom-brand-icons) HACS
set. Leave out all `tv_app` items and the app column disappears.

**Source names** must match the Apple TV's `source_list` exactly — check
**Developer Tools → States → your Apple TV → source_list**.

## Music tab and Play on

![Music tab](images/music.svg)

Now Playing for one speaker — a Music Assistant player works best (the
artwork, shuffle/repeat and grouping are all reliable).

- Artwork, title, artist, progress bar with elapsed / total time.
- **Previous / Play-Pause / Next**; **shuffle** (left) and **repeat** (right,
  cycles off → all → one) light up white when active.
- **Mute** and a **volume slider** that follows the speaker.
- **Play on** (speaker icon, top right) — opens a list of other speakers.

![Play on](images/play-on.svg)

Tap a speaker to add it to the music playing in this room; tap again to remove
it. A checkmark shows which speakers are grouped, and the corner icon lights
up while any are. Grouping uses `media_player.join` / `unjoin` with this room's
player as the leader.

```yaml
- path: tabs/music.yaml
  vars: { tab_position: 3, music_player: media_player.living_room }
- path: items/speaker.yaml
  vars: { slot: 1, name: "Kitchen", entity: media_player.kitchen, leader: media_player.living_room }
```

No `speaker` items → no Play on button.

## Favorites tab

![Favorites tab](images/favorites.svg)

A grid of artwork tiles (three per row, more scroll). Tap to play on the
chosen speaker; shuffle can be switched on per tile.

```yaml
- path: tabs/favorites.yaml
  vars: { tab_position: 4 }
- path: items/favorite.yaml
  vars:
    slot: 1
    name: "Morning Jazz"
    image: ../www/playlist_icons/morning_jazz.png   # square image, compiled into the firmware
    media_content_id: "https://open.spotify.com/playlist/…"
    player: media_player.living_room
    shuffle: "true"     # "false" for radio stations
```

`media_content_id` is anything your player's `media_player.play_media`
accepts — Spotify URLs, Music Assistant URIs (`apple_music--xxxx://playlist/…`),
radio station URIs, etc. A quick way to find one: play the item in Music
Assistant and copy its URI from the item's details.

## Weather

![Weather sheet](images/weather.svg)

The status bar shows the current condition and temperature; **tap it** for
the weather sheet: current conditions, today's high/low, humidity, wind and UV,
the next 15 hours (every 3 hours) and the next 5 days with any rain.

```yaml
- path: features/weather.yaml
  vars:
    weather_entity: weather.home
    forecast_entity: sensor.panel_weather_forecast          # from ha/panel_weather.yaml
    outdoor_temp_entity: sensor.backyard_temperature        # optional: your own thermometer
```

- The forecast needs [`ha/panel_weather.yaml`](../ha/panel_weather.yaml) in Home
  Assistant (HA no longer stores forecasts as attributes; this package fetches
  them every 30 minutes). Without it the sheet shows current conditions only.
- `outdoor_temp_entity` (optional) replaces the forecast's temperature with a
  local sensor such as a rooftop weather station.

## Climate

![Climate sheet](images/climate.svg)

The status bar shows the **indoor temperature** with a small house icon —
**orange while heating, blue while cooling**. Tap it for the thermostat:

- **Heat / Cool:** drag the dial or use − / +; the target, the current
  temperature and what the system is doing are shown in the middle.
- **Auto** (HA's heat/cool mode): **Heat to** and **Cool to** rows, each with
  − / +.
- **Off / Heat / Cool / Auto** buttons at the bottom.

Changes are sent about a second after your last tap, so several taps become
one command.

```yaml
- path: features/climate.yaml
  vars: { climate_entity: climate.first_floor, climate_name: "First Floor" }
```

## Status icons (chips)

Small icons in the status bar that appear only when something needs
attention — for example the garage door open, packages waiting (with a count),
or a red/green sailboat for a marine advisory.

```yaml
- path: features/status_chip.yaml
  vars:
    chip_id: garage                         # unique name
    slot: 1                                 # 1 = rightmost
    entity: cover.garage_door
    icon: "\U000F06DA"                      # mdi-garage-open
    color: "0xFF9F0A"                       # orange
    show_when: "open,opening"               # states that show it, or "nonzero"
    show_value: "false"                     # "true" shows the number next to it
```

- **Icons** are [Material Design Icons](https://pictogrammers.com/library/mdi/)
  code points: open an icon, copy its code (e.g. `F06DA`) and write it as
  `"\U000F06DA"`. The panels use MDI **v7.4.47** — icons added later won't show.
- **Numbers:** `show_when: "nonzero"` with `show_value: "true"` shows e.g. a
  package icon with "2" while a counter is above zero.
- **Two-state icon** (always visible, green or red): include two chips on
  complementary entities (e.g. `binary_sensor.advisory` and
  `binary_sensor.no_advisory`), each with `show_when: "on"` and its own color.
- About three fit next to the clock.

## Marine forecast

![Marine forecast](images/marine.svg)

A full-text marine forecast, opened by tapping a status chip (for example the
advisory sailboat). A red banner shows any advisory; the periods scroll.

```yaml
- path: features/marine.yaml
  vars:
    marine_entity: sensor.marine_forecast   # attributes period_1..5, forecast_1..5, advisory_text
    title: "Marine Forecast"
    open_chip_1: noaa_red                   # chip_id(s) of the chips that open it
    open_chip_2: noaa_green
```

The entity needs `period_N` / `forecast_N` attributes (N = 1 to 5) and an
`advisory_text` attribute (empty or `None` when there's no advisory). Any
text source shaped like that works.

## Camera pop-ups

![Camera pop-up](images/camera-popup.svg)

When an entity turns on — a gate opening, a doorbell press, motion — the
panel wakes and shows that camera, refreshing every few seconds. It closes on
**Dismiss**, a tap on the image, or after a minute.

```yaml
- path: features/camera_popup.yaml
  vars:
    popup_id: doorbell                      # unique per pop-up
    title: "Doorbell"
    trigger_entity: binary_sensor.front_doorbell_visitor
    camera_entity: camera.front_doorbell
```

Include it once per trigger. Snapshots come through Home Assistant's camera
proxy (so `ha_url` must be right); a camera's low-resolution "fluent" or
substream entity loads fastest. Each refresh briefly pauses touch while the
image downloads, which is why the default is every 5 seconds
(`camera_refresh_seconds`).

## Messages from Home Assistant

![Message banner](images/message.svg)

Any automation can put a banner on any panel: an icon, a title and a line or
two of text. It sits on top of everything, disappears after a set time (or
stays until tapped), and wakes a sleeping panel.

```yaml
# In an HA automation or script (needs ha/panel_messages.yaml)
action: script.panel_message
data:
  panels: [esp-living-room-panel, esp-kitchen-panel]
  title: Washer done
  message: Time to move the laundry to the dryer.
  icon: washer       # info alert bell door gate mail washer car check
  seconds: 30        # 0 = until tapped
```

Each panel also offers `esphome.<panel_name>_show_message` and
`esphome.<panel_name>_clear_message` directly (dashes in the name become
underscores). See [Home Assistant side](home-assistant.md#messages) for
examples.

## Settings

![Settings](images/settings.svg)

Tap the **gear**. The sheet scrolls; it closes with **Done** or when the
screen dims. Every setting is saved on the panel and also appears in Home
Assistant (device page → Configuration), so you can change panels remotely.

| Section | Setting | What it does |
|---|---|---|
| Display | **Brightness** | Backlight level when the panel is in use. |
| Slider color | **Hue / Saturation / Brightness** | Color of every slider, the progress bar and switches. Saturation 0 gives a grey; in HA this is the **Slider Color** light, with a color wheel (turn it off for the default). |
| | **Text on fill** | Color of slider names/percentages where the colored fill is under them: Auto (dark or white by contrast), Light or Dark. |
| Screen | **Dim after** | 15 s, 30 s, 1 min, 2 min or Never. |
| | **Turn off after** | 1, 5, 10, 30 min or Never. |
| | **Sleep screen** | What "off" looks like: Blank, Clock or Red clock. |
| Night | **Night mode**, **Starts**, **Ends**, **Night brightness** | See [Night mode](#night-mode). |
| Options | **24-hour clock** | 14:30 instead of 2:30pm. |
| | **Auto-open TV & Music** | Bring up the TV or Music tab when playback starts. |
| | **Messages wake at full brightness** | Off: messages wake a sleeping panel dimly. On: to your brightness. |
| | **Lock settings with PIN** | See [PIN lock](#pin-lock). |
| About | | See [About and restart](#about-and-restart). |

## Screen dimming, sleep and the night clock

![Night clock](images/night-clock.svg)

- After **Dim after**, the backlight fades to the dim level (30%, or your
  brightness if that's lower). A touch brings it back and works normally.
- After **Turn off after**, the panel sleeps:
  - **Blank** — backlight off. The first tap only wakes the panel; it never
    presses whatever is underneath.
  - **Clock / Red clock** — a large, dim clock and date that shifts a few
    pixels every minute. A tap wakes the panel.
- Any open sheet (Settings, Weather, Climate…) closes when the screen dims, so
  the panel always wakes to its tabs.
- **Presence wake** (optional) wakes a sleeping panel to the dim level when an
  occupancy sensor turns on:

  ```yaml
  - path: features/presence_wake.yaml
    vars: { presence_entity: binary_sensor.living_room_occupancy }
  ```

- **Anti-burn:** between 1 and 6 am the panel shows moving "snow" for a while
  each hour to exercise every pixel.

## Night mode

Settings → **Night**: turn on **Night mode** and choose when night **Starts**
(8 PM–12 AM) and **Ends** (5–9 AM), and the **Night brightness** (20 / 30 / 45%).
During those hours:

- The screen never gets brighter than the night brightness — when touched,
  when a message arrives, or when woken by presence.
- When the panel sleeps it shows the **red night clock**, whatever the Sleep
  screen setting says.
- At the start and end of the night an awake screen eases to the new
  brightness.

Typical use: bedside and kids' rooms.

## PIN lock

![PIN keypad](images/pin.svg)

Keeps the Settings sheet behind a 4-digit PIN — useful in kids' rooms, guest
rooms and rentals.

1. Settings → Options → turn on **Lock settings with PIN**.
2. Choose a 4-digit PIN on the keypad. The switch turns on once it's set.
3. From now on the gear opens the keypad; the right PIN opens Settings. It
   relocks when the screen next dims.

**Forgot the PIN?** In Home Assistant, on the panel's device page, turn off
**Settings PIN Lock** or clear **Settings PIN**. Automations can lock and
unlock the panel the same way.

## About and restart

At the bottom of Settings: device name, panel version, ESPHome version, IP
address, Wi-Fi network and signal, uptime, and the reason for the **last
restart** (useful for spotting power problems — see
[Troubleshooting](troubleshooting.md)). **Hold to restart** reboots the panel
(holding prevents accidental restarts). IP, signal, uptime, reset reason and
Restart are also in Home Assistant.
