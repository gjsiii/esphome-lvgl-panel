# Changelog

## v0.6.0 — unreleased

- **Marine forecast from NOAA It All, with a three-colour sailboat.**
  `features/marine.yaml` now draws its own status-bar sailboat: red while a
  marine hazard is in effect, yellow when one is coming (or a watch is out,
  or the forecast has a headline), green otherwise. The sheet shows hazards
  in effect on a red card and upcoming ones on an amber card. Data comes from
  the [NOAA It All](https://github.com/dawg-io/noaa_it_all) integration's
  marine entry through the new `ha/panel_marine.yaml` package
  (`sensor.panel_marine`). **Upgrading (breaking):** install
  `ha/panel_marine.yaml` (set your zone), delete the two sailboat
  `status_chip` lines from your display file, and change the `marine` vars to
  `marine_entity: sensor.panel_marine`, `title`, `chip_slot` (`open_chip_1` /
  `open_chip_2` are gone).
- **Play on: a volume slider per speaker.** A speaker grouped with this
  room's music shows its own slider under its name in the Play on sheet; the
  main slider still sets this room's speaker. No display file changes.
- **Holiday themes** (`features/holidays.yaml`, optional): Halloween,
  Christmas, Valentine's Day and St. Patrick's Day each bring their colour
  (slider color), an icon by the status-bar clock, a countdown on the night
  clock and a few icons drifting across it. Off until you turn on the
  panel's **Holiday Theme** switch in Home Assistant, so each room can
  differ; **Holiday Preview** (disabled in HA by default) shows a theme
  early.
- **Match volumes** in Play on: one tap sets every grouped speaker to this
  room's volume.
- **Now playing on the night clock:** a dimmer line with the title and
  artist while music plays (panels with the Music tab).
- **Sleep screen notes** (`features/sleep_notes.yaml` with the new
  `ha/panel_notes.yaml` package): a **Panel Sleep Message** text helper shown
  under the night clock's date, and birthdays from Date helpers named
  `Birthday: …` (a countdown the week before, "Happy birthday, …!" on the
  day). A message, or a birthday on the day, shows the clock even when Sleep
  screen is Blank.
- **Reminders from Schedule helpers** (`ha/panel_notes.yaml`): a Schedule
  helper named `Reminder: …` puts a banner on the listed panels when each
  time block starts.
- **Weather in colour:** condition icons in the status bar and on the
  weather sheet are tinted by condition (yellow sun, blue rain, orange
  storms…) and switch to moons after sunset. Rain amounts (now light blue)
  and the humidity · wind · UV line are larger. The 5-day rows get
  Apple-Weather-style range bars (scaled to the week, cool-to-warm colours,
  a dot for the current temperature on Today), the header shows the next
  sunrise and sunset, and a new optional `feels_like_entity` adds "Feels
  like" under the high/low. **Upgrading:** copy the new
  `ha/panel_weather.yaml` into HA (adds night flags and sun times; older
  panels ignore them) and reload template entities.
- **Larger small print:** captions, section headers and help text go from
  13 to 16 px (`font_caption`; 24 px on the P4) so they read from across the
  room. Layouts that got tight were adjusted (update notice, About card,
  Night help, Play on help, Apple TV labels). Favorite tile names stay at
  13 px (new `font_small`). A display file that includes only
  `core/theme.yaml` (no hardware package) needs `px: 1` in its substitutions.
- **Music tab: volume buttons.** Volume − / + either side of play/pause
  (5% per tap, `music_volume_step`); previous / next and shuffle / repeat
  move into the empty space beside the artwork. The full-width volume slider
  stays.
- **TV tab: Apps sheet, power out of the way.** The thin column of small app
  buttons becomes an **Apps** button that opens a sheet of large tiles, each
  the app's logo and name on its brand colour (`items/tv_app.yaml` gains
  optional `color` and `name`). Power moves to the top-right corner as a
  small grey button (tap: on, hold: off), and the d-pad grows to 240 px.
- **480 boards: 16 KB main-loop stack** (was ESPHome's 8 KB) and a **Loop
  Stack Free** diagnostic sensor, as on the P4. Two family room crashes
  faulted inside the FreeRTOS tick interrupt, the signature of a loop-stack
  overflow corrupting kernel data. Costs 8 KB of internal RAM.
- **Fewer resets on 480 boards:** Spotify (`i.scdn.co`, `mosaic`,
  `image-cdn-*`) and Apple Music (`*.mzstatic.com`) artwork now loads over
  plain http, like SiriusXM logos already did (`art_http` in
  `core/images.yaml`). An https fetch could block the panel for up to 8 s
  during the TLS handshake and trip the task watchdog while favorites art
  loaded. The panels' `http_request` warnings (missing etag headers) are
  hidden; failures still log.
- Docs: new Holiday themes and Play on illustrations; both features listed
  with their entities in [Home Assistant side](docs/home-assistant.md).

## v0.5.0 — 2026-10-13

- **Favorites from Music Assistant** (`tabs/ma_favorites.yaml` with the new
  `ha/panel_ma_favorites.yaml` package): your Music Assistant favorites
  (playlists, radio, albums, artists) as a live artwork grid with category
  chips, Shuffle and refresh. Change favorites in Music Assistant; no
  reinstall. Up to 36, on any board (artwork is kept in PSRAM; the tab needs
  little internal RAM). The hand-picked `tabs/favorites.yaml` is unchanged.
  **Update `ha/panel_ma_favorites.yaml` in Home Assistant together with the
  panels**: the list now uses short codes to save panel memory.
- **More free memory, especially on 480×480 panels:** album art, TV art,
  favorites artwork and camera pop-ups now share two image loaders
  (`core/images.yaml`) instead of one each. Every loader keeps an ~18 KB
  decoder in internal RAM once used; a typical 480 panel had four, so about
  35 KB is freed. HTTPS artwork (Spotify, Apple Music) now uses PSRAM for its
  TLS buffers on the Guition boards.
- **Powder day** (snow report): after at least `powder_inches` (default 3)
  of new snow in 24 hours, the sleeping panel shows the clock with the total
  under the date ("14″ new snow · Breckenridge"), even when Sleep screen is
  Blank. A panel already asleep switches over when the report updates.
- **Settings → Voice** (panels with voice): choose the wake word (Okay Nabu
  or Hey Jarvis), mute it, and set the reply volume on the panel itself.
- **Over-the-air updates now use the API key** (encrypted and authenticated)
  instead of a separate OTA password. This saves about 3.5 KB of flash and
  some RAM, and removes ESPHome's "'ota' password wastes significant flash"
  warning. **Upgrading:** the `ota_password` substitution is no longer used;
  delete it from your display file (leaving it does no harm). Updating from
  a panel built with ESPHome 2026.9 or later installs normally over Wi-Fi.
  For a panel last built with an older ESPHome, first install v0.4.0 with a
  current ESPHome (or update over USB).
- Music tab: Music Assistant album art now shows, including SiriusXM channel
  logos. Its image server sends PNG
  by default; the panel now asks it for a 256 px JPEG.
- Favorites: a tapped tile shows "Starting…" for a few seconds and further
  taps wait, so impatient taps no longer queue several reloads in Music
  Assistant (which then played through them one after another).
- Fixed on the ESP32-P4 board: an occasional restart (Fault, sometimes after
  a flash of solid colour) when the panel was tapped awake from the night
  clock. Redrawing the whole screen needed about 8.2 KB of the main loop's
  8 KB stack; it now has 16 KB. A new **Loop Stack Free** diagnostic sensor
  shows the least headroom since boot.
- Fixed on 720×720: the lower part of Settings (Restart, About this project)
  sat too high and overlapped the rows above.
- Fixed a compiler format warning in Settings → About (uptime).
- Fixed: the status-bar mic icon showed muted when the wake word was on, and
  the reverse.
- Docs: new illustrations of the snow report, Timer tab (with Custom… and
  Time's up), Music Assistant favorites, light color sheet and About; the
  Lights tab now shows a shade slider; README gallery has a third row. Also
  the powder-day sleep screen and Settings → Voice.

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
