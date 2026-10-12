# Getting started

This guide takes a new panel to a working display in Home Assistant. Plan on about 30 minutes for the first one; later panels
take a few minutes each.

## What you need

- A supported panel:
  - **Guition ESP32-S3-4848S040**: 4″ 480×480, inexpensive, no audio.
  - **Waveshare ESP32-P4-WIFI6-Touch-LCD-4B**: 4″ 720×720, sharper and
    faster, with a speaker and microphones for [voice](features.md#voice).
    It fits a standard 86 mm wall box.
- A **5 V USB power supply of at least 2 A** and a short, good-quality USB-C
  data cable. Thin or long cables cause brown-outs and random restarts.
- **Home Assistant** with the **ESPHome Device Builder** add-on (or ESPHome
  installed elsewhere) — version **2026.9.0 or newer**.
- A computer with **Chrome or Edge** for the first (USB) install.
- Optional but recommended: **Music Assistant**, for the Music tab, speaker
  grouping and favorites.

## 1. Install the Home Assistant packages

Two small HA files power the weather forecast and the message banner. Copy
them from this repo into Home Assistant:

| File | Copy to | Provides |
|---|---|---|
| [`ha/panel_weather.yaml`](../ha/panel_weather.yaml) | `/config/packages/panel_weather.yaml` | `sensor.panel_weather_forecast` (hourly and daily forecast for the weather sheet) |
| [`ha/panel_messages.yaml`](../ha/panel_messages.yaml) | `/config/packages/panel_messages.yaml` | `script.panel_message` (send a banner to one or more panels) |

If you don't use packages yet, add this to `configuration.yaml`:

```yaml
homeassistant:
  packages: !include_dir_named packages
```

In `panel_weather.yaml`, change `source: weather.home` if your weather entity
has another name. Then **restart Home Assistant** and check
**Developer Tools → States** for `sensor.panel_weather_forecast`.

## 2. Create the display file

Each panel has one small file of its own; everything else comes from this
repository.

1. In the ESPHome dashboard, open the file editor (or use any editor on
   `/config/esphome/`).
2. Copy [`examples/display-template.yaml`](../examples/display-template.yaml) to
   `/config/esphome/<your-panel-name>.yaml` — for example
   `esp-living-room-panel.yaml`.
3. Work through the lines marked **◀**:
   - `name:` — lowercase letters, digits and hyphens only. It becomes the
     network name and the prefix of the panel's HA actions.
   - `ha_url` — your Home Assistant address (used to load artwork), e.g.
     `http://192.168.1.10:8123`.
   - Your scenes, lights, TV, speakers and favorites (see
     [Using the panel](features.md) for each).
   - Delete any feature you don't want — every one is optional.
4. Pin a release: `ref: v0.3.0` (see [Updating](#6-updating)).

### Secrets

The template reads its passwords from `/config/esphome/secrets.yaml`, so no
password ever sits in the display file or in this repository:

```yaml
wifi_ssid: "My Wi-Fi"
wifi_password: "…"
living_room_panel_api_key: "…"        # 32 random bytes, base64
living_room_panel_ap_password: "…"    # fallback hotspot, 8+ characters
```

Make an API key on any Linux/macOS terminal with
`head -c 32 /dev/urandom | base64`, or let the ESPHome dashboard generate one
when you create a new device and copy it over.

## 3. First install (USB)

The first install must be over USB because it sets up the panel's flash
layout. After that, every update is over Wi-Fi.

**Waveshare P4:** in the display file, use
`hardware/waveshare-esp32-p4-86-4b.yaml` instead of the Guition file. Early
boards have a pre-production chip and need `p4_engineering_sample: true`
(see [Display file reference](display-file.md#hardware)). If you're not sure,
install once and read the boot log: `esp32p4-eco2` or a chip revision below
v3.0 means an engineering sample. A build for the wrong revision stops right
after the bootloader.

1. Plug the panel into your computer.
2. In the ESPHome dashboard: your panel → **⋮ → Install → Plug into this
   computer**. ESPHome compiles (the first build takes several minutes), then
   asks for the serial port.
3. Choose the panel's port (often "USB Single Serial" or "CH340") and click
   **Install**.
   - No port listed? Install the CH340 USB driver, or try another cable.
   - Won't connect? Unplug, **hold the BOOT button while plugging it back in**,
     and try again.
4. The panel restarts and shows the clock and your tabs.

*Alternative:* **Install → Manual download → Factory format**, then flash the
file at [web.esphome.io](https://web.esphome.io).

## 4. Add it to Home Assistant

1. HA discovers the panel (**Settings → Devices & services**). Click **Add** and
   enter the API key from your secrets.
2. **Important:** open the ESPHome integration entry for the panel →
   **Configure** → turn on **"Allow the device to perform Home Assistant
   actions"**. Without this every button on the panel is ignored (the HA log
   says "Service call … rejected").
3. The device page now lists the panel's settings (Configuration) and
   diagnostics — see [Home Assistant side](home-assistant.md#entities-each-panel-adds).

## 5. Make it yours

On the panel, tap the **gear** (top right) for brightness, slider color,
screen timing, night mode and the PIN lock; tap the **weather** for the
forecast. [Using the panel](features.md) walks through every screen.

## 6. Updating

Each display file names a release of this repository with `ref:`. To update:

1. Read the [changelog](../CHANGELOG.md) for anything marked **Breaking**.
2. Change `ref: v0.3.0` to the new tag.
3. ESPHome dashboard → **Update All** (or install each panel). Updates are over
   Wi-Fi.

## Developing locally

If you want to change the shared files themselves, clone this repository into
`/config/esphome/panel/` and include files directly instead of from GitHub —
edits take effect on the next install:

```yaml
packages:
  hardware: !include panel/hardware/guition-4848s040.yaml
  core: !include panel/core/core.yaml
  light_1: !include { file: panel/items/light.yaml, vars: { slot: 1, name: "Ceiling", entity: light.living_room_ceiling } }
```

The remote (GitHub) and local forms take exactly the same files and `vars`.
