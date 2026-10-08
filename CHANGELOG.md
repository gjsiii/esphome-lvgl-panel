# Changelog

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
