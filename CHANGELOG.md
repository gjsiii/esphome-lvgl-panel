# Changelog

## v0.5.0 — unreleased

- **Favorites from Music Assistant** (`tabs/ma_favorites.yaml` with the new
  `ha/panel_ma_favorites.yaml` package): your Music Assistant favorites
  (playlists, radio, albums, artists) as a live artwork grid with category
  chips, Shuffle and refresh. Change favorites in Music Assistant; no
  reinstall. Up to 36; for the Waveshare P4 (artwork is kept in PSRAM). The
  hand-picked `tabs/favorites.yaml` is unchanged.
- Music tab: Music Assistant album art now shows. Its image server sends PNG
  by default; the panel now asks it for a 256 px JPEG.
- Fixed on 720×720: the lower part of Settings (Restart, About this project)
  sat too high and overlapped the rows above.
- Docs: new illustrations of the snow report, Timer tab (with Custom… and
  Time's up), Music Assistant favorites, light color sheet and About; the
  Lights tab now shows a shade slider; README gallery has a third row.

## v0.4.0 — 2026-10-12

- **Waveshare ESP32-P4-WIFI6-Touch-LCD-4B** (4″ 720×720) support:
  `hardware/waveshare-esp32-p4-86-4b.yaml`, with the board's speaker and
  microphones. Settings for early "engineering sample" chips, CPU and PSRAM
  speed, display pixel clock and screen rotation (`p4_*`, `dsi_pclk`,
  `lvgl_rotation`).
- **Voice** (`features/voice_assistant.yaml`): "Okay Nabu" wake word (or
  "Hey Jarvis") and Home Assistant Assist. The panel wakes, shows Listening /
  Thinking / Replying with what it heard and the answer, and speaks the
  reply. A mic icon in the status bar mutes the wake word ("Mute Wake Word"
  in HA). Replies and HA announcements play on the "Panel Speaker" media
  player.
- **Timer tab** (`tabs/timer.yaml`, needs the voice feature): preset buttons
  (`preset_1` … `preset_6`, minutes), a custom timer, and up to three
  countdowns with +1 min and cancel. Timers set by voice ("Okay Nabu, set a
  pasta timer for 10 minutes") show in the same list. When one ends the panel
  wakes, shows "Time's up" and chimes until Stop; a status-bar chip shows the
  time left.
- **Backlight is now a configuration entity**, so Assist no longer counts it
  as one of the room's lights ("turn off the kitchen lights" used to blank the
  screen). A tap now relights a backlight turned off from Home Assistant.
  **Upgrading:** Home Assistant keeps existing panels' Backlight exposed to
  Assist; turn it off under Settings → Voice assistants → Expose.
- Every size in the shared files now scales with the board (`px`, set by the
  hardware package). Nothing changes on 480×480 panels. Contributors: write
  sizes as `${N*px}`; see docs/customizing.md#sizes-and-scaling.
- Hardware packages now set the LVGL draw buffer (`lvgl_buffer_size`).
  **Breaking** only for a custom hardware package: it must set `px` and
  `lvgl_buffer_size` in its `substitutions:`.

## v0.3.0 — 2026-10-12

- Settings → About this project: QR code, repository name and link
  (github.com/gjsiii/esphome-lvgl-panel) and the panel version.
- Cleaning mode: the spray-bottle button in the Settings header (or the
  "Cleaning Mode" button in HA) turns touch off for 30 seconds with a
  countdown, so the screen can be wiped.
- Light color sheet: hold a light's name for brightness, warmth (color
  temperature) and color (hue, saturation, a white swatch and seven color
  swatches). Only the sections the light supports are shown; lights that only
  dim ignore the hold. Tapping the name still toggles.
- Shades, blinds and curtains (`items/cover.yaml`): a position slider in the
  lights list; tap the name to open/close, or stop while moving. New
  `lights_title` substitution to rename the LIGHTS heading.
- Snow report (`features/snow_report.yaml`): a snowflake status chip with the
  last 24 hours of new snow, and a winter-themed sheet with new snow (24 h /
  48 h / 72 h / 7 days), base and summit depth, season total, lifts and runs
  open and opening day.
- Update notice: with `ha/panel_updates.yaml` in HA (reads the newest version
  tag from GitHub), Settings shows an "Update available" card and About shows
  whether the panel is up to date.
- Docs: mixed Hue + Lutron rooms now use an HA scene plus the Hue scene on one
  chip (comma-separated `entity`) instead of a script, with a recipe for
  "follow" automations; smart bulbs should stay powered and use their own group.

## v0.2.0 — 2026-10-08

- Documentation: `docs/` guides (getting started, using the panel, display
  file reference, Home Assistant side, customizing, troubleshooting) with
  illustrations of every screen; expanded example display file.
- Settings sheet: slider color (Hue / Saturation / Brightness sliders with a
  live preview — any color or grey), dim after, turn off after, 24-hour clock,
  auto-open TV & Music. All are saved on the panel and exposed to Home
  Assistant as config entities; the slider color is a "Slider Color" RGB light,
  so HA shows a color wheel for it (off = default color).
- Slider labels stay readable on any slider color: text over the fill turns
  dark or white automatically ("Slider Text Color": Auto, Light or Dark).
- Camera pop-ups (`features/camera_popup.yaml`): any HA entity turning on
  (gate, doorbell, motion) wakes the panel and shows a live-refreshing camera
  snapshot; one include per trigger.
- Messages from HA: `show_message` / `clear_message` actions on every panel,
  shown as a banner (icon, title, text, auto-hide or until tapped), plus
  `ha/panel_messages.yaml` with `script.panel_message` for several panels.
  Setting "Messages wake at full brightness" restores the Settings brightness.
- Night clock: new "Sleep Screen" setting (Blank, Clock, Red clock). Instead
  of going dark, the panel shows a large dim clock and date that shifts a few
  pixels each minute; a tap wakes the panel without pressing anything.
- Screen timing is now a setting. **Breaking:** the `idle_dim_timeout` and
  `idle_off_timeout` substitutions are replaced by `default_dim_after` and
  `default_off_after` (option names, e.g. "30 s", "5 min").
- Any open sheet (Settings, Weather) closes when the screen dims or turns off.
- Stability: camera pop-ups request a scaled snapshot from HA (448×252)
  instead of the full-resolution image, and image downloads (album art, TV
  art, cameras) run one at a time — fixes crashes (abort / watchdog) when a
  pop-up and artwork loaded together. Pop-ups show "Loading camera…" instead
  of the previous visit's picture until the first frame arrives.
- Memory: Wi-Fi/network buffers and allocations above 4 KB use PSRAM, keeping
  the internal heap free. New HA diagnostics: Free Memory, Largest Free Block,
  Free PSRAM, Loop Time (with Reset Reason).
- **Flash: 16 MB.** The hardware package now uses the board's full 16 MB flash
  (was the 4 MB default). Existing panels need one USB flash to switch; their
  saved settings reset to defaults.
- Removed the built-in web page (`web_server`) to keep the firmware inside the
  1.75 MB app slot of the default 4 MB flash layout; use HA or the ESPHome
  dashboard instead. Online images use the new `image: platform: online_image`
  form (the old `online_image:` block is removed in ESPHome 2027.1).
- Scene chips keep the 3 + 2 layout (row widths set at boot).
- Music tab: full-width volume slider (follows the speaker) with mute; shuffle
  and repeat at the ends of the transport row
  (repeat cycles off → all → one). Replaces the − / mute / + buttons.
- TV tab: optional column of round app buttons with white logos right of the d-pad (`items/tv_app.yaml`,
  select_source; logos supplied per house, e.g. /config/www/tv_app_icons/)
  and skip back / forward buttons beside the volume pill.
- Lights tab: tap a light or fan name to toggle it on/off.
- Action chips (`items/action_chip.yaml`): a scenes-row chip that runs any HA
  action, e.g. "Off" for a room without an off scene.
- Climate (`features/climate.yaml`): indoor temperature next to the weather
  (house icon orange while heating, blue while cooling); tap for a thermostat
  sheet with a dial, − / +, and Off / Heat / Cool / Auto (heat-to / cool-to).
- Music "Play on" sheet (`items/speaker.yaml`): add or remove other speakers
  (Music Assistant / Sonos groups); the corner icon lights up while grouped.
- Settings PIN lock: "Lock settings with PIN" asks for a new 4-digit PIN; the
  gear then opens a keypad. Relocks when the screen dims. PIN and lock are
  also HA entities (PIN can be changed or cleared from HA).
- Weather: optional `outdoor_temp_entity` (e.g. a rooftop station) for the
  current temperature.
- Marine forecast sheet (`features/marine.yaml`), opened from a status chip.
- Night mode (Settings → Night): between the chosen hours the screen stays at
  or below the night brightness and sleeps to the red night clock.
- Status-bar chips (`features/status_chip.yaml`): an icon (and optional number)
  shown while an entity is in given states or above zero, e.g. garage open,
  package count.
- Settings → About: device name, panel version, ESPHome version, IP address,
  Wi-Fi network and signal, uptime, last restart reason, and hold-to-restart.
  IP, Wi-Fi signal, reset reason,
  uptime and Restart are also HA entities.
- Status-bar connection icon only turns red when Home Assistant disconnects
  (not when other API clients such as the log viewer do).

## v0.1.0 — 2026-10-07

First shared release.

- Guition ESP32-S3-4848S040 hardware package.
- Core: iOS/Android-style dark theme, status bar (time, weather, HA connection,
  settings), bottom tab bar, settings sheet with remembered brightness.
- Screen care: dim after 30 s, backlight off after 5 min, touch wake that never
  presses a hidden button, nightly anti-burn.
- Lights tab with scene chips, light sliders and fan sliders; hides the scenes
  row when a room has none.
- TV tab for Apple TV with now-playing artwork; separate volume and mute players.
- Music tab for Music Assistant players with album art.
- Favorites tab with compiled-in artwork tiles.
- Weather sheet with current conditions, 15-hour and 5-day forecast
  (requires `ha/panel_weather.yaml` in Home Assistant).
- Optional presence wake.
- TV and Music tabs select themselves when playback starts.
