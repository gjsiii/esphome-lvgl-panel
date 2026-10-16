# Customizing and extending

## Colors

The whole theme comes from a few palette colors in
[`core/theme.yaml`](../core/theme.yaml). Override any of them in a display
file's `substitutions:`:

| Name | Default | Used for |
|---|---|---|
| `c_bg` | `0x000000` | Screen background. |
| `c_surface` | `0x1C1C1E` | Cards, buttons, slider tracks. |
| `c_surface_2` | `0x2C2C2E` | Pressed buttons, selected tab, inner circles. |
| `c_separator` | `0x38383A` | Hairlines, progress track. |
| `c_text` | `0xFFFFFF` | Primary text and icons. |
| `c_text_2` | `0x8E8E93` | Secondary text, captions, unselected tabs. |
| `c_accent` | `0xF2F2F7` | Default slider color, "Done", play button. |
| `c_on_accent` | `0x000000` | Icons drawn on the accent (play button). |
| `c_selected` | `0x636366` | Selected segment in segmented controls. |

The slider color itself is a user setting (Settings → Slider color, or the
*Slider Color* light in HA); `c_accent` is only its default.

## Fonts and icons

- Text uses **Inter** from Google Fonts: `font_caption` and `font_body` 16
  (captions are told apart by their grey colour), `font_title` 20,
  `font_time` 22, `font_small` 13 (favorite tile names only), plus large
  digit-only fonts for the clock, the weather and the thermostat. Sizes are
  in 480-design pixels and scale by `px` on larger screens.
- A display file that uses only `core/theme.yaml` (no hardware package) must
  set `px: 1` in its `substitutions:`.
- Icons come from **Material Design Icons v7.4.47**. Fonts only contain the
  glyphs listed in `core/theme.yaml`; to use another icon in a shared file,
  add its code point there. (Status chips compile their own icon, so any MDI
  icon works there.)
- To check an icon's code point, look it up in the
  [v7.4.47 stylesheet](https://raw.githubusercontent.com/Templarian/MaterialDesign-Webfont/v7.4.47/css/materialdesignicons.css)
  (`.mdi-<name>::before { content: "\F06DA"; }`). Icons renamed or removed in
  v7 show as a different symbol.

## Sizes and scaling

The screens are designed once, for a 480×480 panel, and every size is
multiplied by `px`, which the hardware package sets (1 on 480×480 boards, 1.5
on 720×720). Write every pixel value in a shared file that way:

| Write | Not | Why |
|---|---|---|
| `width: ${440*px}` | `width: 440` | Scales with the board. |
| `x: ${13*px//1}` | `x: ${13*px}` | Odd numbers: 13 × 1.5 = 19.5, and ESPHome rejects half pixels. `//1` rounds down. The 480 build won't catch a missing `//1`; only a 720 build will. |
| `x: -${18*px}` | `x: ${-18*px}` | `${-` is Jinja's whitespace-trim marker: the minus sign is silently dropped. |
| `lv_obj_set_y(obj, ${(34*px)\|int});` | `lv_obj_set_y(obj, 34);` | In C++ lambdas and text (URLs), `\|int` gives a whole number. |
| `resize: "${(180*px)\|int}x${(180*px)\|int}"` | `resize: [180, 180]` | Images: quoted, whole numbers. |
| `{ x: "${66*px}", width: "${66*px}" }` | `{ x: ${66*px} }` | Inside a one-line `{ … }` map, quote it. |

Leave `0`, 1 px hairlines, percentages, `SIZE_CONTENT` and the `999` pill
radius as they are. Font sizes follow the same rule (`size: ${13*px//1}`).

To find odd values missing `//1`:

```sh
grep -rnE '\$\{[0-9]*[13579]\*px\}' --include=*.yaml .
```

A new hardware package sets `px` (screen width ÷ 480) and `lvgl_buffer_size`
in its `substitutions:`.

## How the panel is put together

ESPHome merges packages, but only at the top level: a package can't reach
inside another package's widget tree. So every tab and item here uses one
pattern:

1. **Build on a holding page.** The package declares its widgets on its own
   LVGL page marked `skip: true` (never shown).
2. **Move into place at boot.** An `esphome: on_boot:` lambda moves the widgets
   to their real home — `lv_tabview_add_tab()` for a tab, `lv_obj_set_parent()`
   for an item or a sheet.
3. **Order by boot priority.** Higher priorities run first:

   | Priority | Step |
   |---|---|
   | `-100` | Core sets up flex layouts (scene row, slider list, chip row). |
   | `-10<tab_position>` (-102 … -109) | Tabs add themselves in tab-bar order. |
   | `-150` | Sheets (weather, climate, camera) move onto `ui_root`. |
   | `-200` | The voice mic button moves into the status-chip row (rightmost). |
   | `-20<slot>` (-201 … -209) | Items move into their containers in slot order. |
   | `-300` | Core styles the tab bar, sizes scene chips, shows the main page. |
   | `-310` | Settings apply saved values; the UI is marked ready. |

4. **Containers start empty.** ESPHome rejects a flex `layout:` on a container
   defined without widgets, so containers that items fill get their layout in
   a boot lambda instead.

### Sheets

Full-screen pages (Settings, Weather, Climate, Play on, camera pop-ups, the PIN
keypad) are children of `ui_root`, after the status bar and tab view. Hiding a
sheet is just `lvgl.widget.hide`; the core closes **every** child of `ui_root`
after the first two when the screen dims, so new sheets get that for free.

### Settings that survive reboots

Settings are ESPHome `select`, `switch`, `light` and `text` entities with
`restore_value` / `restore_mode`, which also makes them HA entities. The
panel's own controls call `select.set` / `switch.turn_on`, and a
`sync_settings_ui` script redraws the controls when a value changes from
anywhere.

## Writing a new item

As an example, a cover (blinds) slider modeled on `items/light.yaml`. It reuses
the light rows' ids, so it shares slot numbers with lights and fans (and gets
their slider styling and label colors for free):

```yaml
# items/cover.yaml — vars: slot, name, entity
esphome:
  on_boot:
    - priority: -20${slot}
      then:
        - lambda: "lv_obj_set_parent(id(light_row_${slot}), id(lights_list));"

sensor:
  - platform: homeassistant
    id: cover_pos_${slot}
    entity_id: ${entity}
    attribute: current_position
    on_value:
      - lambda: "lv_slider_set_value(id(light_slider_${slot}), (int) x, LV_ANIM_OFF);"

lvgl:
  pages:
    - id: holding_cover_${slot}
      skip: true
      widgets:
        - obj:
            id: light_row_${slot}
            width: ${440*px}
            height: ${56*px}
            styles: transparent
            widgets:
              - slider:
                  id: light_slider_${slot}
                  width: 100%
                  height: 100%
                  min_value: 0
                  max_value: 100
                  on_release:
                    - homeassistant.action:
                        action: cover.set_cover_position
                        data:
                          entity_id: ${entity}
                          position: !lambda "return (int) x;"
              - label:
                  text: "${name}"
                  align: LEFT_MID
                  x: ${18*px}
```

Rules of thumb:

- Every widget and component `id` must include `${slot}` (or another per-include
  var) so the item can be included many times.
- Write sizes as `${N*px}` (see [Sizes and scaling](#sizes-and-scaling)).
- Never hard-code a site's entity IDs or addresses in a shared file — take them
  as vars or substitutions.
- Don't put `!secret` in a shared file: in a GitHub package it would be looked
  up in the downloaded repository, not the house's `secrets.yaml`.

## Releasing a new version

1. Bump `panel_version` in `core/base.yaml` and add a section to `CHANGELOG.md`
   (mark anything that changes existing display files as **Breaking**).
2. Commit, tag (`git tag -a v0.6.0 -m v0.6.0`) and push the commit and the tag.
3. Each house changes `ref:` to the new tag and installs.

To regenerate the documentation illustrations after a design change, run
`bash docs/images/make-illustrations.sh`.
