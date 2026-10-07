# Changelog

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
