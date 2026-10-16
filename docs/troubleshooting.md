# Troubleshooting

## Buttons do nothing

- **"Allow the device to perform Home Assistant actions"** isn't on. HA's log
  shows `Service call … rejected`. Turn it on in the panel's ESPHome
  integration options (Settings → Devices & services → ESPHome → the panel →
  Configure).
- The **connection icon is red**: the panel isn't connected to Home Assistant.
  Check Wi-Fi signal (Settings → About) and that the panel is adopted in HA.
- An entity ID in the display file is wrong (HA logs a warning naming it).

## The build is too large / "app partitions are too small"

The panel's firmware must fit its flash layout. The hardware package uses the
board's full 16 MB; panels first flashed with an older 4 MB layout need **one
USB install** to switch (over-the-air updates can't change the layout).

## The panel restarts on its own, or goes back to older firmware

Check **Settings → About → Last restart** (or the *Reset Reason* entity in HA)
after an unexpected restart:

| Reset reason | Likely cause |
|---|---|
| Brownout, Power on | **Power**: a weak supply or a thin/long USB cable. Use a 5 V ≥ 2 A supply and a short, thick cable. |
| Panic, Exception, Watchdog | A software crash — please open an issue with the reason and the ESPHome log. |
| Software | A normal restart or update. |

**Crash details.** After a crash the panel logs `CRASH DETECTED ON PREVIOUS
BOOT` with a reason, a PC address and a backtrace; the panels' warnings and
errors also land in Home Assistant's log (**Settings → System → Logs**, or
`ha core logs`). The same record is printed again every time Home Assistant
reconnects, so several identical records are usually one crash. To turn the
addresses into function names you need the **ELF file of the exact build that
crashed** — in the ESPHome dashboard, **⋮ → Download ELF file** right after
installing (a later compile replaces it) — then
`addr2line -pfiaC -e firmware.elf <addresses>` with the ESP32 toolchain.

Crashes fixed in v0.6.0:

- **Task watchdog while favorites or album art loads (480 boards):** an
  https download from Spotify could hold the panel for up to 8 s during the
  encryption handshake. Artwork from hosts that also serve plain http
  (Spotify, Apple Music, SiriusXM) now loads over http.
- **Fault / LoadProhibited inside the FreeRTOS tick interrupt (480 boards,
  now and then):** the main loop, which also draws the screen, overflowed
  ESPHome's 8 KB stack and corrupted the system's task data. The Guition
  package now gives it 16 KB like the P4, and adds the **Loop Stack Free**
  sensor; it should stay well above 1000 B.

After an over-the-air update, the panel keeps the previous firmware until the
new one has run for about a minute. If it loses power or crashes in that
minute, it **rolls back** to the previous version on the next start — so
frequent restarts can look like "my update disappeared".

## The screen seems to freeze for a moment

Downloads (album art, TV art, camera snapshots) briefly pause the screen and
touch while they arrive. Album and TV art are fetched once per track, after a
short delay; camera pop-ups refresh every 5 seconds. If freezes are long,
check the panel's Wi-Fi signal and that `ha_url` points at a fast local
address (an IP rather than a cloud URL).

## No album art, TV art or camera image

- `ha_url` must be the address the **panel** can reach (usually
  `http://<HA IP>:8123`).
- Some TV apps don't share artwork with HA — the corner stays empty.

## Music Assistant favorites: empty tab, or a music note instead of artwork

- **"Loading favorites…" never goes away:** `sensor.panel_ma_favorites` is
  missing or empty. Check the package is installed, `ma_entry` is right, and
  reload Template entities (Developer Tools → YAML).
- **A tile shows a music note:** its artwork couldn't be decoded (the panel
  reads JPEG and PNG; progressive JPEGs aren't supported) or there is none.
  The tile still plays.
- **New favorites don't appear:** tap the refresh icon on the tab; the list is
  otherwise re-read every 15 minutes.
- **Every tile shows a music note after an update:** the panel and
  `ha/panel_ma_favorites.yaml` in Home Assistant are from different releases.
  Copy the package from the same release and reload Template entities.

## The weather sheet shows dashes

`sensor.panel_weather_forecast` is missing or `unavailable`: install
[`ha/panel_weather.yaml`](../ha/panel_weather.yaml), check `source:`, restart
HA, and look at the sensor in Developer Tools → States.

## An icon shows the wrong symbol

The panels use Material Design Icons **v7.4.47**. Icons removed or renamed in
v7 (for example `mdi-sailing`) display a different glyph. Look up the code in
the [v7.4.47 stylesheet](https://raw.githubusercontent.com/Templarian/MaterialDesign-Webfont/v7.4.47/css/materialdesignicons.css).

## "Light turned on with deprecated effect None" (Hue)

Not caused by the panel: an HA scene saved with an older Home Assistant stores
`effect: None` for Hue lights. Edit the scene in `scenes.yaml` and change
`effect: None` to `effect: "off"`, then reload scenes.

## Forgot the settings PIN

On the panel's device page in HA, turn off **Settings PIN Lock** or clear
**Settings PIN**.

## The first USB install won't connect

- Use Chrome or Edge, and a USB cable that carries data.
- Install the CH340 USB driver if no serial port appears.
- Hold the **BOOT** button while plugging the panel in, then connect.
- Or download the factory image (Install → Manual download → Factory format)
  and flash it at [web.esphome.io](https://web.esphome.io).

## Waveshare P4 panel

- **Stops right after the bootloader, or restarts in a loop:** the chip
  revision setting is wrong. Early boards need
  `p4_engineering_sample: true`; production boards (chip revision v3.0 or
  later in the boot log) need it `false`. Install over USB to recover.
- **A flickering or noisy band at one edge of the screen:** the display is
  running short of memory bandwidth. Lower `p4_psram_speed` to `100MHz`, then
  `dsi_pclk` to `28MHz`.
- **The picture is sideways or upside down:** set `lvgl_rotation` to `"90"`,
  `"180"` or `"270"` to match the mounting. Touch follows automatically.
- **Restarted (Fault) when woken from the night clock, sometimes after a
  flash of solid colour:** fixed in v0.5.0. Redrawing the whole screen needed
  just over the main loop's 8 KB stack; the hardware package now gives it
  16 KB (`loop_task_stack_size`). The **Loop Stack Free** diagnostic sensor
  shows the least headroom since boot; it should stay well above 1000 B.
- **The screen goes dark during an update:** on purpose; it avoids flicker
  while the new firmware is written.
- **Restarts in a loop with "vApplicationGetTimerTaskMemory" in the USB
  log:** the chip ran out of internal memory while starting. The hardware
  package keeps the Wi-Fi link's buffers in PSRAM (`esp32_hosted:
  use_psram: true`) for this; keep that if you copy the board settings.

## The screen goes black after "turn off the … lights"

Assist counted the panel's own **Backlight** as one of the room's lights.
Since v0.4.0 the Backlight is a configuration entity, which Assist leaves out,
but Home Assistant keeps panels added earlier exposed: turn it off under
Settings → Voice assistants → **Expose** (search "Backlight"). A tap brings
the screen back.

## Voice doesn't respond

- The mic icon in the status bar is red: the wake word is muted. Tap it.
- The panel's own speaker is playing music: the wake word pauses until it
  stops (the panel can't listen and play at once).
- Nothing happens after "Okay Nabu": check that Assist works in Home
  Assistant (Settings → Voice assistants → ⋮ → Debug), that the panel's
  *Assistant* select names that pipeline, and that "Allow the device to
  perform Home Assistant actions" is on.
- It hears you but replies "Error": the pipeline's speech-to-text or
  text-to-speech isn't reachable. HA's voice debug view shows which step
  failed.

## Compile warnings you can ignore

- `GPIO19/GPIO20 is used by the USB-Serial-JTAG interface` — those pins drive
  the display and touch on the Guition board.
- `Font Inter … is missing 1 glyph` — a rare accent mark.
