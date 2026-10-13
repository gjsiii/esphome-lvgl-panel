#!/bin/bash
# Redraws the docs/images/*.svg illustrations (layout and palette follow
# core/*.yaml). Run from anywhere: bash docs/images/make-illustrations.sh
O="$(cd "$(dirname "$0")" && pwd)"
F='font-family="Inter, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif"'
head() { echo "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"480\" height=\"480\" viewBox=\"0 0 480 480\" $F>"; echo '<rect width="480" height="480" rx="18" fill="#000"/>'; }
foot() { echo '</svg>'; }
wifi() { echo "<g transform=\"translate($1 $2)\" fill=\"none\" stroke=\"#8E8E93\" stroke-width=\"2.2\" stroke-linecap=\"round\"><path d=\"M-9 -3a13 13 0 0 1 18 0\"/><path d=\"M-5.5 1a8 8 0 0 1 11 0\"/><circle cx=\"0\" cy=\"5\" r=\"1.6\" fill=\"#8E8E93\" stroke=\"none\"/></g>"; }
gear() { echo "<g transform=\"translate($1 $2)\"><circle r=\"7.5\" fill=\"none\" stroke=\"#8E8E93\" stroke-width=\"3.5\" stroke-dasharray=\"3.4 2.5\"/><circle r=\"4.2\" fill=\"none\" stroke=\"#8E8E93\" stroke-width=\"2\"/></g>"; }
sun() { echo "<g transform=\"translate($1 $2)\" stroke=\"#FFF\" stroke-width=\"2\" stroke-linecap=\"round\"><circle r=\"4.5\" fill=\"none\"/><path d=\"M0 -9v2.5M0 6.5V9M-9 0h2.5M6.5 0H9M-6.4 -6.4l1.8 1.8M4.6 4.6l1.8 1.8M-6.4 6.4l1.8-1.8M4.6 -4.6l1.8-1.8\"/></g>"; }
house() { echo "<g transform=\"translate($1 $2)\" fill=\"none\" stroke=\"$3\" stroke-width=\"2\" stroke-linejoin=\"round\"><path d=\"M-8 0L0 -7L8 0V8H-8Z\"/><path d=\"M0 1v4\" stroke-linecap=\"round\"/></g>"; }
boat() { echo "<g transform=\"translate($1 $2)\" fill=\"$3\"><path d=\"M-1 -9L-1 4L-8 4Z\"/><path d=\"M1 -7L7 4L1 4Z\"/><path d=\"M-9 6H9L6 9H-6Z\"/></g>"; }
status() { # time [chips]
  sun 24 18; echo '<text x="38" y="25" fill="#FFF" font-size="20" font-weight="600">70°</text>'
  house 106 18 "$3"; echo '<text x="124" y="25" fill="#FFF" font-size="20" font-weight="600">72°</text>'
  echo "<text x=\"240\" y=\"26\" fill=\"#FFF\" font-size=\"22\" font-weight=\"600\" text-anchor=\"middle\">$1</text>"
  [ -n "$2" ] && echo "$2"
  wifi 412 19; gear 456 18; }
tabs() { # active index 0..3, list
  echo '<rect x="0" y="424" width="480" height="56" fill="#000"/><rect x="0" y="424" width="480" height="1" fill="#38383A"/>'
  local i=0 n=$#; local w=$(( 460 / n ))
  for t in "$@"; do local x=$((10 + i*w));
    if [ $i -eq $ACT ]; then echo "<rect x=\"$((x+3))\" y=\"432\" width=\"$((w-6))\" height=\"40\" rx=\"12\" fill=\"#2C2C2E\"/>"; c="#FFF"; else c="#8E8E93"; fi
    echo "<text x=\"$((x + w/2))\" y=\"458\" fill=\"$c\" font-size=\"16\" font-weight=\"500\" text-anchor=\"middle\">$t</text>"; i=$((i+1)); done; }
chip() { echo "<rect x=\"$1\" y=\"$2\" width=\"$3\" height=\"48\" rx=\"24\" fill=\"#1C1C1E\"/><text x=\"$(( $1 + $3/2 ))\" y=\"$(( $2 + 30 ))\" fill=\"#FFF\" font-size=\"16\" font-weight=\"500\" text-anchor=\"middle\">$4</text>"; }
slider() { # y name pct fillcolor textoncolor
  local fw=$(( 440 * $3 / 100 ))
  echo "<rect x=\"20\" y=\"$1\" width=\"440\" height=\"56\" rx=\"16\" fill=\"#1C1C1E\"/>"
  [ $fw -gt 0 ] && echo "<rect x=\"20\" y=\"$1\" width=\"$fw\" height=\"56\" rx=\"16\" fill=\"$4\"/>"
  local nc="#8E8E93"; [ $fw -gt 150 ] && nc="$5"; local pc="#8E8E93"; [ $fw -gt 420 ] && pc="$5"
  echo "<text x=\"38\" y=\"$(( $1 + 34 ))\" fill=\"$nc\" font-size=\"16\" font-weight=\"500\">$2</text><text x=\"442\" y=\"$(( $1 + 34 ))\" fill=\"$pc\" font-size=\"16\" font-weight=\"500\" text-anchor=\"end\">$3%</text>"; }
hdr() { echo "<text x=\"20\" y=\"42\" fill=\"#FFF\" font-size=\"20\" font-weight=\"600\">$1</text><text x=\"415\" y=\"42\" fill=\"#F2F2F7\" font-size=\"20\" font-weight=\"600\" text-anchor=\"middle\">Done</text>"; }
sec() { echo "<text x=\"$1\" y=\"$2\" fill=\"#8E8E93\" font-size=\"13\" font-weight=\"500\" letter-spacing=\"1\">$3</text>"; }
round() { echo "<circle cx=\"$1\" cy=\"$2\" r=\"$3\" fill=\"${5:-#1C1C1E}\"/><text x=\"$1\" y=\"$(( $2 + 7 ))\" fill=\"${6:-#FFF}\" font-size=\"${7:-20}\" text-anchor=\"middle\">$4</text>"; }

# ── Lights ──────────────────────────────────────────────────────────────────
ACT=0; { head; status "8:42pm" "$(boat 368 18 '#30D158')" "#8E8E93"
 sec 24 61 SCENES; chip 20 70 140 Daytime; chip 170 70 140 Bright; chip 320 70 140 Dim; chip 20 128 215 "Movie Lights"; chip 245 128 215 Off
 sec 24 191 LIGHTS; slider 212 "Recessed Lights" 0 "#F2F2F7" "#1C1C1E"; slider 278 "Chandelier" 75 "#F2F2F7" "#1C1C1E"; slider 344 "Shades" 60 "#F2F2F7" "#1C1C1E"
 tabs Lights TV Music Favorites; foot; } > $O/lights.svg

# ── TV ──────────────────────────────────────────────────────────────────────
ACT=1; { head; status "8:42pm" "" "#0A84FF"
 echo '<rect x="12" y="48" width="104" height="104" rx="12" fill="#2C3E50"/><text x="64" y="106" fill="#FFF" font-size="13" text-anchor="middle">artwork</text>'
 echo '<text x="12" y="172" fill="#FFF" font-size="13">Friends</text><text x="12" y="190" fill="#8E8E93" font-size="13">HBO Max</text>'
 echo '<circle cx="240" cy="154" r="110" fill="#1C1C1E"/><circle cx="240" cy="154" r="42" fill="#2C2C2E"/>'
 echo '<g fill="none" stroke="#FFF" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M230 76l10-10 10 10"/><path d="M230 232l10 10 10-10"/><path d="M162 144l-10 10 10 10"/><path d="M318 144l10 10-10 10"/></g>'
 for i in 0 1 2 3; do y=$((70 + i*56)); echo "<circle cx=\"415\" cy=\"$((y+23))\" r=\"23\" fill=\"#1C1C1E\"/>"; done
 echo '<text x="415" y="99" fill="#FFF" font-size="11" font-weight="700" text-anchor="middle">PBS</text><text x="415" y="155" fill="#FFF" font-size="16" font-weight="700" text-anchor="middle">N</text><text x="415" y="211" fill="#FFF" font-size="10" font-weight="700" text-anchor="middle">D+</text><text x="415" y="267" fill="#FFF" font-size="18" font-weight="700" text-anchor="middle">›</text>'
 round 126 316 30 "⏻"; round 202 316 30 "←"; round 278 316 30 "⌂"; round 354 316 30 "⏯" "#1C1C1E" "#FFF" 18
 round 76 384 28 "⏪" "#1C1C1E" "#FFF" 16; round 404 384 28 "⏩" "#1C1C1E" "#FFF" 16
 echo '<rect x="120" y="356" width="240" height="56" rx="28" fill="#1C1C1E"/><text x="160" y="391" fill="#FFF" font-size="22" text-anchor="middle">−</text><text x="240" y="390" fill="#FFF" font-size="16" text-anchor="middle">mute</text><text x="320" y="391" fill="#FFF" font-size="22" text-anchor="middle">+</text>'
 tabs Lights TV Music Favorites; foot; } > $O/tv.svg

# ── Music ───────────────────────────────────────────────────────────────────
ACT=2; { head; status "8:42pm" "" "#8E8E93"
 echo '<defs><linearGradient id="art" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#3A6073"/><stop offset="1" stop-color="#16222A"/></linearGradient></defs>'
 echo '<rect x="150" y="42" width="180" height="180" rx="14" fill="url(#art)"/><text x="240" y="138" fill="#FFF" font-size="13" text-anchor="middle" opacity=".7">album art</text>'
 echo '<circle cx="444" cy="68" r="0"/><g transform="translate(444 68)" fill="#8E8E93"><rect x="-11" y="-9" width="9" height="18" rx="2"/><rect x="2" y="-9" width="9" height="18" rx="2"/></g>'
 echo '<text x="240" y="251" fill="#FFF" font-size="20" font-weight="600" text-anchor="middle">The Gold Ring</text><text x="240" y="276" fill="#8E8E93" font-size="16" text-anchor="middle">Liam O’Flynn</text>'
 echo '<rect x="40" y="286" width="400" height="4" rx="2" fill="#38383A"/><rect x="40" y="286" width="150" height="4" rx="2" fill="#F2F2F7"/>'
 echo '<text x="40" y="309" fill="#8E8E93" font-size="13">1:27</text><text x="440" y="309" fill="#8E8E93" font-size="13" text-anchor="end">3:51</text>'
 echo '<text x="46" y="356" fill="#FFF" font-size="20" text-anchor="middle">⇄</text><text x="128" y="358" fill="#FFF" font-size="26" text-anchor="middle">⏮</text>'
 echo '<circle cx="240" cy="348" r="32" fill="#F2F2F7"/><g fill="#000"><rect x="228" y="334" width="8" height="28" rx="2"/><rect x="244" y="334" width="8" height="28" rx="2"/></g>'
 echo '<text x="352" y="358" fill="#FFF" font-size="26" text-anchor="middle">⏭</text><text x="434" y="356" fill="#8E8E93" font-size="20" text-anchor="middle">↻</text>'
 echo '<text x="36" y="410" fill="#8E8E93" font-size="18" text-anchor="middle">🔈</text><rect x="66" y="391" width="400" height="28" rx="14" fill="#1C1C1E"/><rect x="66" y="391" width="140" height="28" rx="14" fill="#F2F2F7"/>'
 tabs Lights TV Music Favorites; foot; } > $O/music.svg

# ── Favorites ───────────────────────────────────────────────────────────────
ACT=3; { head; status "8:42pm" "" "#8E8E93"
 cols=("#355C7D" "#C06C84" "#6C5B7B" "#2A9D8F" "#E9C46A" "#264653"); names=("Peaceful Piano" "Party Starters" "Spa" "Peaceful Ireland" "Molly’s KA Songs" "Let’s Golf")
 for i in 0 1 2 3 4 5; do x=$((12 + (i%3)*158)); y=$((48 + (i/3)*184)); echo "<rect x=\"$x\" y=\"$y\" width=\"140\" height=\"140\" rx=\"12\" fill=\"${cols[$i]}\"/><text x=\"$((x+70))\" y=\"$((y+162))\" fill=\"#FFF\" font-size=\"13\" font-weight=\"500\" text-anchor=\"middle\">${names[$i]}</text>"; done
 tabs Lights TV Music Favorites; foot; } > $O/favorites.svg

# ── Weather sheet ───────────────────────────────────────────────────────────
{ head; hdr Weather
 echo '<g transform="translate(60 112)" stroke="#FFF" stroke-width="4" stroke-linecap="round"><circle r="15" fill="none"/><path d="M0 -30v7M0 23v7M-30 0h7M23 0h7M-21 -21l5 5M16 16l5 5M-21 21l5-5M16 -16l5-5"/></g>'
 echo '<text x="108" y="136" fill="#FFF" font-size="72" font-weight="300">70°</text><text x="252" y="96" fill="#FFF" font-size="20" font-weight="600">Sunny</text><text x="252" y="124" fill="#8E8E93" font-size="16">H 74°  ·  L 58°</text>'
 echo '<text x="240" y="174" fill="#8E8E93" font-size="13" text-anchor="middle">Humidity 61%  ·  Wind 9 mph SW  ·  UV 3</text>'
 echo '<rect x="16" y="184" width="448" height="92" rx="14" fill="#1C1C1E"/>'
 t=(Now 6pm 9pm 12am 3am 6am); v=(70 68 63 60 58 59); ic=(☀ ☀ ☾ ☾ ☁ ⛅)
 for i in 0 1 2 3 4 5; do x=$((18 + i*74 + 37)); echo "<text x=\"$x\" y=\"206\" fill=\"#8E8E93\" font-size=\"13\" text-anchor=\"middle\">${t[$i]}</text><text x=\"$x\" y=\"240\" fill=\"#FFF\" font-size=\"22\" text-anchor=\"middle\">${ic[$i]}</text><text x=\"$x\" y=\"266\" fill=\"#FFF\" font-size=\"16\" text-anchor=\"middle\">${v[$i]}°</text>"; done
 echo '<rect x="16" y="286" width="448" height="166" rx="14" fill="#1C1C1E"/>'
 d=(Today Thu Fri Sat Sun); lo=(58 55 57 61 60); hi=(74 70 72 77 75); di=(☀ ⛅ 🌧 ☀ ⛅); rn=("" "" "0.24 in" "" "")
 for i in 0 1 2 3 4; do y=$((286 + 4 + i*32 + 22)); echo "<text x=\"32\" y=\"$y\" fill=\"#FFF\" font-size=\"16\">${d[$i]}</text><text x=\"134\" y=\"$y\" fill=\"#FFF\" font-size=\"18\">${di[$i]}</text><text x=\"162\" y=\"$y\" fill=\"#8E8E93\" font-size=\"13\">${rn[$i]}</text><text x=\"372\" y=\"$y\" fill=\"#8E8E93\" font-size=\"16\" text-anchor=\"end\">${lo[$i]}°</text><text x=\"440\" y=\"$y\" fill=\"#FFF\" font-size=\"16\" text-anchor=\"end\">${hi[$i]}°</text>"; done
 echo '<text x="240" y="472" fill="#8E8E93" font-size="13" text-anchor="middle">Updated 8:30pm</text>'; foot; } > $O/weather.svg

# ── Climate sheet ───────────────────────────────────────────────────────────
{ head; hdr "First Floor"
 echo '<path d="M151.6 279.4 A125 125 0 1 1 328.4 279.4" fill="none" stroke="#1C1C1E" stroke-width="18" stroke-linecap="round"/>'
 echo '<path d="M151.6 279.4 A125 125 0 0 1 252 66.6" fill="none" stroke="#0A84FF" stroke-width="18" stroke-linecap="round"/><circle cx="252" cy="66.6" r="13" fill="#FFF"/>'
 echo '<text x="240" y="212" fill="#FFF" font-size="72" font-weight="300" text-anchor="middle">72°</text><text x="240" y="246" fill="#8E8E93" font-size="13" text-anchor="middle">Now 74°  ·  Cooling</text>'
 round 64 288 28 "−" "#1C1C1E" "#FFF" 26; round 416 288 28 "+" "#1C1C1E" "#FFF" 26
 echo '<rect x="16" y="392" width="448" height="50" rx="12" fill="#1C1C1E"/><rect x="224" y="396" width="110" height="42" rx="9" fill="#636366"/>'
 m=(Off Heat Cool Auto); for i in 0 1 2 3; do echo "<text x=\"$((20 + i*110 + 55))\" y=\"423\" fill=\"#FFF\" font-size=\"16\" text-anchor=\"middle\">${m[$i]}</text>"; done; foot; } > $O/climate.svg

# ── Settings (top) ──────────────────────────────────────────────────────────
{ head; hdr Settings
 sec 32 92 DISPLAY; echo '<rect x="16" y="102" width="448" height="118" rx="14" fill="#1C1C1E"/><text x="32" y="134" fill="#FFF" font-size="16">Brightness</text><text x="448" y="134" fill="#8E8E93" font-size="16" text-anchor="end">80%</text>'
 echo '<rect x="70" y="162" width="340" height="44" rx="14" fill="#2C2C2E"/><rect x="70" y="162" width="272" height="44" rx="14" fill="#F2F2F7"/><text x="44" y="192" fill="#8E8E93" font-size="18" text-anchor="middle">☼</text><text x="436" y="192" fill="#8E8E93" font-size="22" text-anchor="middle">☀</text>'
 sec 32 248 "SLIDER COLOR"; echo '<circle cx="446" cy="242" r="10" fill="#AEAEB2" stroke="#38383A"/>'
 echo '<rect x="16" y="258" width="448" height="222" rx="14" fill="#1C1C1E"/><defs><linearGradient id="hue"><stop offset="0" stop-color="#F00"/><stop offset=".17" stop-color="#FF0"/><stop offset=".33" stop-color="#0F0"/><stop offset=".5" stop-color="#0FF"/><stop offset=".67" stop-color="#00F"/><stop offset=".83" stop-color="#F0F"/><stop offset="1" stop-color="#F00"/></linearGradient><linearGradient id="sat"><stop offset="0" stop-color="#FFF"/><stop offset="1" stop-color="#0A84FF"/></linearGradient><linearGradient id="bri"><stop offset="0" stop-color="#000"/><stop offset="1" stop-color="#FFF"/></linearGradient></defs>'
 echo '<text x="32" y="298" fill="#FFF" font-size="16">Hue</text><rect x="132" y="276" width="316" height="28" rx="14" fill="url(#hue)"/><circle cx="352" cy="290" r="16" fill="#FFF" stroke="#0006"/>'
 echo '<text x="32" y="350" fill="#FFF" font-size="16">Saturation</text><rect x="132" y="328" width="316" height="28" rx="14" fill="url(#sat)"/><circle cx="148" cy="342" r="16" fill="#FFF" stroke="#0006"/>'
 echo '<text x="32" y="402" fill="#FFF" font-size="16">Brightness</text><rect x="132" y="380" width="316" height="28" rx="14" fill="url(#bri)"/><circle cx="340" cy="394" r="16" fill="#FFF" stroke="#0006"/>'
 echo '<text x="32" y="454" fill="#FFF" font-size="16">Text on fill</text><rect x="132" y="428" width="316" height="38" rx="10" fill="#2C2C2E"/><rect x="135" y="431" width="104" height="32" rx="8" fill="#636366"/><text x="187" y="453" fill="#FFF" font-size="16" text-anchor="middle">Auto</text><text x="290" y="453" fill="#FFF" font-size="16" text-anchor="middle">Light</text><text x="393" y="453" fill="#FFF" font-size="16" text-anchor="middle">Dark</text>'
 foot; } > $O/settings.svg

# ── Night clock ─────────────────────────────────────────────────────────────
{ head; echo '<text x="240" y="250" fill="#FF3B30" font-size="120" font-weight="200" text-anchor="middle">10:42</text><text x="240" y="300" fill="#FF3B30" fill-opacity=".7" font-size="20" font-weight="600" text-anchor="middle">Wednesday, October 7</text>'; foot; } > $O/night-clock.svg

# ── Message banner over the Lights tab ──────────────────────────────────────
ACT=0; { head; status "8:42pm" "" "#8E8E93"
 sec 24 61 SCENES; chip 20 70 140 Daytime; chip 170 70 140 Bright; chip 320 70 140 Dim
 sec 24 191 LIGHTS; slider 212 "Recessed Lights" 0 "#F2F2F7" "#1C1C1E"; slider 278 "Chandelier" 75 "#F2F2F7" "#1C1C1E"
 echo '<rect x="12" y="6" width="456" height="84" rx="18" fill="#2C2C2E" stroke="#38383A"/><g transform="translate(46 48)" fill="none" stroke="#FFF" stroke-width="2.4"><rect x="-11" y="-12" width="22" height="24" rx="3"/><circle cx="0" cy="3" r="6"/><path d="M-7 -7h3"/></g>'
 echo '<text x="76" y="38" fill="#FFF" font-size="20" font-weight="600">Washer done</text><text x="76" y="66" fill="#8E8E93" font-size="16">Time to move the laundry to the dryer.</text>'
 tabs Lights TV Music Favorites; foot; } > $O/message.svg

# ── Camera pop-up ───────────────────────────────────────────────────────────
{ head; echo '<text x="20" y="42" fill="#FFF" font-size="20" font-weight="600">Front Gate</text><text x="460" y="42" fill="#8E8E93" font-size="16" text-anchor="end">6:12pm</text>'
 echo '<defs><linearGradient id="cam" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#5B7083"/><stop offset="1" stop-color="#2E3B2E"/></linearGradient></defs><rect x="16" y="66" width="448" height="252" rx="14" fill="url(#cam)"/><text x="240" y="198" fill="#FFF" font-size="14" text-anchor="middle" opacity=".7">live camera snapshot</text>'
 echo '<text x="240" y="342" fill="#8E8E93" font-size="13" text-anchor="middle">Live · updates every 5 s</text><rect x="130" y="368" width="220" height="56" rx="28" fill="#2C2C2E"/><text x="240" y="403" fill="#FFF" font-size="20" font-weight="600" text-anchor="middle">Dismiss</text>'; foot; } > $O/camera-popup.svg

# ── Play on (Kitchen grouped, with its own volume) ─────────────────────────
{ head; hdr "Play on"; echo '<text x="20" y="82" fill="#8E8E93" font-size="13">Tap a speaker to add it to this music, or tap again to remove it.</text>'
 r() { echo "<rect x=\"20\" y=\"$1\" width=\"440\" height=\"56\" rx=\"14\" fill=\"#1C1C1E\"/><text x=\"74\" y=\"$(( $1 + 34 ))\" fill=\"#FFF\" font-size=\"16\">$2</text><g transform=\"translate(44 $(( $1 + 28 )))\" fill=\"#8E8E93\"><rect x=\"-7\" y=\"-11\" width=\"14\" height=\"22\" rx=\"3\"/></g>"; [ "$3" = 1 ] && echo "<path d=\"M424 $(( $1 + 28 ))l6 6 12-12\" fill=\"none\" stroke=\"#F2F2F7\" stroke-width=\"3\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"; }
 v() { # y pct: the grouped speaker's volume row
  echo "<g transform=\"translate(44 $(( $1 + 20 )))\" fill=\"#8E8E93\"><path d=\"M-9 -4h5l6 -6v20l-6 -6h-5z\"/><path d=\"M5 -5a7 7 0 0 1 0 10\" fill=\"none\" stroke=\"#8E8E93\" stroke-width=\"2\" stroke-linecap=\"round\"/></g>"
  echo "<rect x=\"74\" y=\"$(( $1 + 8 ))\" width=\"366\" height=\"24\" rx=\"12\" fill=\"#2C2C2E\"/><rect x=\"74\" y=\"$(( $1 + 8 ))\" width=\"$(( 366 * $2 / 100 ))\" height=\"24\" rx=\"12\" fill=\"#F2F2F7\"/>"; }
 r 100 Kitchen 1; v 160 60; r 210 "Dining Room" 0
 echo '<rect x="120" y="404" width="240" height="48" rx="24" fill="#2C2C2E"/><text x="240" y="435" fill="#FFF" font-size="20" font-weight="600" text-anchor="middle">Match volumes</text>'; foot; } > $O/play-on.svg

# ── PIN keypad ──────────────────────────────────────────────────────────────
{ head; echo '<text x="240" y="54" fill="#FFF" font-size="20" font-weight="600" text-anchor="middle">Enter PIN</text>'
 for i in 0 1 2 3; do x=$((183 + i*38)); f="none"; [ $i -lt 2 ] && f="#FFF"; echo "<circle cx=\"$x\" cy=\"85\" r=\"8\" fill=\"$f\" stroke=\"#FFF\" stroke-width=\"2\"/>"; done
 k=(1 2 3 4 5 6 7 8 9 Cancel 0 ⌫); for i in $(seq 0 11); do x=$((140 + (i%3)*100)); y=$((172 + (i/3)*74)); fs=22; [ "${k[$i]}" = Cancel ] && fs=16; echo "<rect x=\"$((x-42))\" y=\"$((y-32))\" width=\"84\" height=\"64\" rx=\"32\" fill=\"#1C1C1E\"/><text x=\"$x\" y=\"$((y+8))\" fill=\"#FFF\" font-size=\"$fs\" font-weight=\"600\" text-anchor=\"middle\">${k[$i]}</text>"; done; foot; } > $O/pin.svg

# ── Marine forecast ─────────────────────────────────────────────────────────
{ head; hdr "Marine Forecast"
 echo '<rect x="20" y="70" width="440" height="46" rx="12" fill="#3A1513" stroke="#FF453A"/><text x="34" y="99" fill="#FF6961" font-size="16">Small Craft Advisory in effect</text>'
 y=146; for p in "Tonight|West winds 10 to 20 kt. Mostly clear.|Waves 1 to 3 ft." "Thursday|Northwest winds 10 to 15 kt. Mostly sunny.|Waves 1 to 3 ft." "Thursday Night|West winds around 10 kt becoming south|around 5 kt. Partly cloudy. Waves 1 to 2 ft."; do IFS='|' read a b c <<< "$p"; echo "<text x=\"20\" y=\"$y\" fill=\"#FFF\" font-size=\"20\" font-weight=\"600\">$a</text><text x=\"20\" y=\"$((y+26))\" fill=\"#8E8E93\" font-size=\"16\">$b</text><text x=\"20\" y=\"$((y+48))\" fill=\"#8E8E93\" font-size=\"16\">$c</text>"; y=$((y+96)); done; foot; } > $O/marine.svg

# ── Voice ───────────────────────────────────────────────────────────────────
{ head
 echo '<circle cx="240" cy="120" r="62" fill="none" stroke="#1C1C1E" stroke-width="4"/><path d="M240 58a62 62 0 0 1 59.5 44.6" fill="none" stroke="#F2F2F7" stroke-width="4" stroke-linecap="round"/>'
 echo '<g transform="translate(240 120)" fill="#FFF"><rect x="-9" y="-24" width="18" height="30" rx="9"/><path d="M-17 -2a17 17 0 0 0 34 0" fill="none" stroke="#FFF" stroke-width="3.5" stroke-linecap="round"/><rect x="-1.75" y="15" width="3.5" height="10"/></g>'
 echo '<text x="240" y="226" fill="#FFF" font-size="20" font-weight="600" text-anchor="middle">Replying</text>'
 echo '<text x="240" y="262" fill="#8E8E93" font-size="16" text-anchor="middle">Turn off the kitchen lights</text>'
 echo '<text x="240" y="318" fill="#FFF" font-size="20" font-weight="600" text-anchor="middle">Turned off the lights</text>'
 chip 160 408 160 Dismiss; foot; } > $O/voice.svg

# ── Snow report (mid-season, the morning after a storm) ─────────────────────
flake() { # cx cy size color opacity — six arms with side barbs
  local r=$(( $3 / 2 )); local b=$(( $3 / 6 )); local w=$(( $3 / 14 + 1 ))
  echo "<g transform=\"translate($1 $2)\" stroke=\"${4:-#FFF}\" stroke-opacity=\"${5:-1}\" stroke-width=\"$w\" stroke-linecap=\"round\" fill=\"none\">"
  for a in 0 60 120 180 240 300; do echo "<g transform=\"rotate($a)\"><path d=\"M0 0V-$r M0 -$(( r*55/100 ))l-$b -$b M0 -$(( r*55/100 ))l$b -$b\"/></g>"; done; echo "</g>"; }
{ head
 echo '<defs><linearGradient id="snowbg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#0A1830"/><stop offset="1" stop-color="#1E3F6E"/></linearGradient></defs><rect width="480" height="480" rx="18" fill="url(#snowbg)"/>'
 flake 350 40 130 "#FFF" .07; flake 40 450 150 "#FFF" .07
 flake 34 35 24 "#9FD3FF"; echo '<text x="54" y="42" fill="#FFF" font-size="20" font-weight="600">Breckenridge</text><text x="415" y="42" fill="#9FD3FF" font-size="20" font-weight="600" text-anchor="middle">Done</text>'
 card() { echo "<rect x=\"$1\" y=\"$2\" width=\"$3\" height=\"$4\" rx=\"$5\" fill=\"#10274A\" stroke=\"#2E5487\"/>"; }
 card 20 68 440 136 18
 echo '<text x="38" y="96" fill="#9FD3FF" font-size="13" font-weight="500" letter-spacing="1">NEW SNOW  ·  24 HOURS</text><text x="34" y="182" fill="#FFF" font-size="72" font-weight="300">14"</text>'
 echo '<rect x="270" y="86" width="1" height="100" fill="#2E5487"/>'
 r=("48 hours|19\"" "72 hours|22\"" "7 days|31\""); for i in 0 1 2; do IFS='|' read a b <<< "${r[$i]}"; y=$((106 + i*36)); echo "<text x=\"288\" y=\"$y\" fill=\"#9FB6D6\" font-size=\"16\">$a</text><text x=\"442\" y=\"$y\" fill=\"#FFF\" font-size=\"20\" font-weight=\"600\" text-anchor=\"end\">$b</text>"; done
 c=("BASE|58\"" "SUMMIT|72\"" "SEASON|187\""); for i in 0 1 2; do IFS='|' read a b <<< "${c[$i]}"; x=$((20 + i*150)); card $x 216 140 92 16; echo "<text x=\"$((x+14))\" y=\"$((216+28))\" fill=\"#9FD3FF\" font-size=\"13\" font-weight=\"500\" letter-spacing=\"1\">$a</text><text x=\"$((x+14))\" y=\"$((216+72))\" fill=\"#FFF\" font-size=\"20\" font-weight=\"600\">$b</text>"; done
 card 20 320 440 104 16
 bar() { echo "<text x=\"38\" y=\"$1\" fill=\"#FFF\" font-size=\"16\">$2</text><text x=\"442\" y=\"$1\" fill=\"#9FB6D6\" font-size=\"16\" text-anchor=\"end\">$3 of $4</text><rect x=\"38\" y=\"$(( $1 + 12 ))\" width=\"404\" height=\"6\" rx=\"3\" fill=\"#0A1830\"/><rect x=\"38\" y=\"$(( $1 + 12 ))\" width=\"$(( 404 * $3 / $4 ))\" height=\"6\" rx=\"3\" fill=\"#9FD3FF\"/>"; }
 bar 348 "Lifts open" 33 35; bar 392 "Runs open" 168 187
 echo '<text x="240" y="456" fill="#9FD3FF" font-size="13" font-weight="500" text-anchor="middle">Open for the season</text>'; foot; } > $O/snow.svg

# ── Light color sheet ───────────────────────────────────────────────────────
{ head; echo '<text x="20" y="42" fill="#FFF" font-size="20" font-weight="600">Chandelier</text>'
 echo '<circle cx="354" cy="34" r="22" fill="#1C1C1E"/><g transform="translate(354 34)" fill="none" stroke="#FFD60A" stroke-width="2.6" stroke-linecap="round"><path d="M-6.5 -7.5a10 10 0 1 0 13 0"/><path d="M0 -11v9"/></g>'
 echo '<rect x="380" y="12" width="90" height="44" rx="22" fill="#1C1C1E"/><text x="425" y="42" fill="#F2F2F7" font-size="20" font-weight="600" text-anchor="middle">Done</text>'
 sec 24 80 BRIGHTNESS; echo '<text x="456" y="80" fill="#8E8E93" font-size="13" text-anchor="end">75%</text>'
 echo '<rect x="20" y="88" width="440" height="56" rx="16" fill="#1C1C1E"/><rect x="20" y="88" width="330" height="56" rx="16" fill="#F2F2F7"/>'
 sec 24 174 WARMTH; echo '<text x="456" y="174" fill="#8E8E93" font-size="13" text-anchor="end">2700K</text>'
 echo '<defs><linearGradient id="ct"><stop offset="0" stop-color="#FF9A3C"/><stop offset="1" stop-color="#D6E6FF"/></linearGradient></defs><rect x="42" y="188" width="396" height="40" rx="20" fill="url(#ct)"/><circle cx="128" cy="208" r="18" fill="#FFF" stroke="#0006"/>'
 sec 24 262 COLOR; echo '<rect x="42" y="276" width="396" height="40" rx="20" fill="url(#hue)"/><circle cx="96" cy="296" r="18" fill="#FFF" stroke="#0006"/>'
 echo '<defs><linearGradient id="hue"><stop offset="0" stop-color="#F00"/><stop offset=".17" stop-color="#FF0"/><stop offset=".33" stop-color="#0F0"/><stop offset=".5" stop-color="#0FF"/><stop offset=".67" stop-color="#00F"/><stop offset=".83" stop-color="#F0F"/><stop offset="1" stop-color="#F00"/></linearGradient><linearGradient id="sat2"><stop offset="0" stop-color="#FFF"/><stop offset="1" stop-color="#FF9A00"/></linearGradient></defs>'
 echo '<rect x="42" y="328" width="396" height="40" rx="20" fill="url(#sat2)"/><circle cx="300" cy="348" r="18" fill="#FFF" stroke="#0006"/>'
 sw=("#F5F1E8" "#FF453A" "#FF9F0A" "#FFD60A" "#30D158" "#0A84FF" "#BF5AF2" "#FF375F"); for i in 0 1 2 3 4 5 6 7; do echo "<circle cx=\"$((44 + i*56))\" cy=\"409\" r=\"24\" fill=\"${sw[$i]}\"/>"; done
 foot; } > $O/light-sheet.svg

# ── Timer tab ───────────────────────────────────────────────────────────────
ACT=1; { head
 echo '<g transform="translate(190 18)" fill="none" stroke="#FFF" stroke-width="2"><circle r="7"/><path d="M0 -4v4l3 2M-2 -10h4" stroke-linecap="round"/></g><text x="202" y="25" fill="#FFF" font-size="20" font-weight="600">4:12</text>'
 sun 24 18; echo '<text x="38" y="25" fill="#FFF" font-size="20" font-weight="600">70°</text>'; house 106 18 "#8E8E93"; echo '<text x="124" y="25" fill="#FFF" font-size="20" font-weight="600">72°</text>'
 echo '<text x="300" y="26" fill="#FFF" font-size="22" font-weight="600" text-anchor="middle">5:48pm</text>'; wifi 412 19; gear 456 18
 trow() { # y name time pct buttons
  echo "<rect x=\"12\" y=\"$1\" width=\"456\" height=\"50\" rx=\"14\" fill=\"#1C1C1E\"/><text x=\"28\" y=\"$(( $1 + 29 ))\" fill=\"#8E8E93\" font-size=\"16\">$2</text><text x=\"358\" y=\"$(( $1 + 31 ))\" fill=\"#FFF\" font-size=\"20\" font-weight=\"600\" text-anchor=\"end\">$3</text>"
  echo "<rect x=\"28\" y=\"$(( $1 + 43 ))\" width=\"424\" height=\"3\" rx=\"2\" fill=\"#2C2C2E\"/><rect x=\"28\" y=\"$(( $1 + 43 ))\" width=\"$(( 424 * $4 / 100 ))\" height=\"3\" rx=\"2\" fill=\"#F2F2F7\"/>"
  [ "$5" = 1 ] && echo "<rect x=\"364\" y=\"$(( $1 + 6 ))\" width=\"52\" height=\"34\" rx=\"17\" fill=\"#2C2C2E\"/><text x=\"390\" y=\"$(( $1 + 28 ))\" fill=\"#FFF\" font-size=\"16\" text-anchor=\"middle\">+1m</text><circle cx=\"443\" cy=\"$(( $1 + 23 ))\" r=\"17\" fill=\"#2C2C2E\"/><path d=\"M437 $(( $1 + 17 ))l12 12M449 $(( $1 + 17 ))l-12 12\" stroke=\"#FFF\" stroke-width=\"2.2\" stroke-linecap=\"round\"/>"; }
 trow 46 "Pasta" "4:12" 42 0; trow 104 "10 min" "7:48" 78 1; trow 162 "Custom 1:30:00" "1:12:05" 80 1
 p=("1 min" "3 min" "5 min" "10 min" "15 min" "30 min"); for i in 0 1 2 3 4 5; do x=$((12 + (i%4)*117)); y=$((288 + (i/4)*68)); echo "<rect x=\"$x\" y=\"$y\" width=\"105\" height=\"58\" rx=\"24\" fill=\"#1C1C1E\"/><text x=\"$((x+52))\" y=\"$((y+35))\" fill=\"#FFF\" font-size=\"20\" font-weight=\"600\" text-anchor=\"middle\">${p[$i]}</text>"; done
 echo '<rect x="246" y="356" width="222" height="58" rx="24" fill="#1C1C1E"/><text x="357" y="391" fill="#FFF" font-size="20" font-weight="600" text-anchor="middle">Custom…</text>'
 tabs Lights Timer Music Favorites; foot; } > $O/timer.svg

# ── Custom timer sheet ──────────────────────────────────────────────────────
{ head; echo '<text x="20" y="42" fill="#FFF" font-size="20" font-weight="600">Custom Timer</text><text x="415" y="42" fill="#F2F2F7" font-size="20" font-weight="600" text-anchor="middle">Cancel</text>'
 roll() { # cx above sel below unit
  echo "<rect x=\"$(( $1 - 55 ))\" y=\"84\" width=\"110\" height=\"156\" rx=\"14\" fill=\"#1C1C1E\"/><rect x=\"$(( $1 - 55 ))\" y=\"140\" width=\"110\" height=\"44\" fill=\"#2C2C2E\"/>"
  echo "<text x=\"$1\" y=\"123\" fill=\"#8E8E93\" font-size=\"20\" font-weight=\"600\" text-anchor=\"middle\">$2</text><text x=\"$1\" y=\"170\" fill=\"#FFF\" font-size=\"20\" font-weight=\"600\" text-anchor=\"middle\">$3</text><text x=\"$1\" y=\"217\" fill=\"#8E8E93\" font-size=\"20\" font-weight=\"600\" text-anchor=\"middle\">$4</text><text x=\"$1\" y=\"268\" fill=\"#8E8E93\" font-size=\"16\" text-anchor=\"middle\">$5</text>"; }
 roll 110 "" 0 1 hours; roll 240 24 25 26 min; roll 370 59 00 01 sec
 echo '<rect x="120" y="380" width="240" height="60" rx="24" fill="#F2F2F7"/><text x="240" y="417" fill="#000" font-size="20" font-weight="600" text-anchor="middle">Start</text>'; foot; } > $O/timer-custom.svg

# ── Time's up ───────────────────────────────────────────────────────────────
{ head
 echo '<g transform="translate(240 120)" fill="#FFF"><path d="M-26 22h52l-7-10v-18a19 19 0 0 0-38 0v18Z"/><circle cy="30" r="7"/><path d="M-40 -18a40 40 0 0 1 12-20M40 -18a40 40 0 0 0-12-20" fill="none" stroke="#FFF" stroke-width="5" stroke-linecap="round"/></g>'
 echo '<text x="240" y="207" fill="#FFF" font-size="20" font-weight="600" text-anchor="middle">Time'"'"'s up</text><text x="240" y="240" fill="#8E8E93" font-size="16" text-anchor="middle">Pasta</text>'
 echo '<rect x="120" y="294" width="240" height="72" rx="24" fill="#F2F2F7"/><text x="240" y="337" fill="#000" font-size="20" font-weight="600" text-anchor="middle">Stop</text>'; foot; } > $O/timer-ring.svg

# ── Favorites from Music Assistant ──────────────────────────────────────────
ACT=3; { head; status "5:48pm" "" "#8E8E93"
 cx=20; c=("All" "Playlists" "Radio" "Albums" "Artists"); w=(44 84 62 72 68); for i in 0 1 2 3 4; do f="#1C1C1E"; [ $i -eq 0 ] && f="#636366"; echo "<rect x=\"$cx\" y=\"46\" width=\"${w[$i]}\" height=\"36\" rx=\"18\" fill=\"$f\"/><text x=\"$((cx + ${w[$i]}/2))\" y=\"69\" fill=\"#FFF\" font-size=\"16\" text-anchor=\"middle\">${c[$i]}</text>"; cx=$((cx + ${w[$i]} + 6)); done
 echo '<circle cx="408" cy="64" r="20" fill="#636366"/><g transform="translate(408 64)" fill="none" stroke="#FFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M-9 -5h4c4 0 6 10 10 10h4M-9 5h4c4 0 6-10 10-10h4"/><path d="M6 -8l3 3-3 3M6 2l3 3-3 3"/></g><circle cx="452" cy="64" r="20" fill="#1C1C1E"/><text x="452" y="71" fill="#8E8E93" font-size="18" text-anchor="middle">↻</text>'
 echo '<defs><clipPath id="grid"><rect x="0" y="92" width="480" height="332"/></clipPath></defs><g clip-path="url(#grid)">'
 cols=("#1DB954" "#C06C84" "#E07A5F" "#355C7D" "#2A9D8F" "#6C5B7B"); names=("Alan Jackson Radio" "Best Dance Songs…" "Beyoncé Radio" "Peaceful Piano" "Spa" "Lo-Fi Beats")
 for i in 0 1 2 3 4 5; do x=$((12 + (i%3)*158)); y=$((96 + (i/3)*184)); echo "<rect x=\"$x\" y=\"$y\" width=\"140\" height=\"140\" rx=\"12\" fill=\"${cols[$i]}\"/><text x=\"$((x+70))\" y=\"$((y+162))\" fill=\"#FFF\" font-size=\"13\" font-weight=\"500\" text-anchor=\"middle\">${names[$i]}</text>"; done
 echo '</g>'; tabs Lights Timer Music Favorites; foot; } > $O/ma-favorites.svg

# ── Powder day on the sleep screen (Sleep screen = Blank, 14" overnight) ───
{ head; echo '<text x="240" y="230" fill="#FFF" font-size="120" font-weight="200" text-anchor="middle">6:48</text><text x="240" y="280" fill="#FFF" fill-opacity=".7" font-size="20" font-weight="600" text-anchor="middle">Thursday, January 15</text>'
 flake 104 323 22 "#FFF"; echo '<text x="123" y="330" fill="#FFF" font-size="20" font-weight="600">14″ new snow · Breckenridge</text>'; foot; } > $O/powder-day.svg

# ── Holiday theme: Halloween on the night clock ────────────────────────────
bat() { # cx cy scale color
  echo "<path transform=\"translate($1 $2) scale($3)\" fill=\"$4\" fill-opacity=\".5\" d=\"M0 -3c2 0 3 -3 3 -3l1 3c3 -4 9 -5 12 -1c-3 0 -5 2 -5 5c-2 -2 -5 -1 -6 1c-1 -2 -3 -2 -5 -1c-2 -1 -4 -1 -5 1c-1 -2 -4 -3 -6 -1c0 -3 -2 -5 -5 -5c3 -4 9 -3 12 1l1 -3s1 3 3 3z\"/>"; }
ghost() { # cx cy scale color
  echo "<g transform=\"translate($1 $2) scale($3)\" fill-opacity=\".5\"><path fill=\"$4\" d=\"M-9 12V-1a9 9 0 0 1 18 0V12l-3 -3l-3 3l-3 -3l-3 3l-3 -3z\"/><circle cx=\"-3.5\" cy=\"-1\" r=\"1.8\" fill=\"#000\"/><circle cx=\"3.5\" cy=\"-1\" r=\"1.8\" fill=\"#000\"/></g>"; }
pumpkin() { # cx cy color
  echo "<g transform=\"translate($1 $2)\"><ellipse cx=\"-4\" cy=\"2\" rx=\"6\" ry=\"8\" fill=\"$3\"/><ellipse cx=\"4\" cy=\"2\" rx=\"6\" ry=\"8\" fill=\"$3\"/><ellipse cx=\"0\" cy=\"2\" rx=\"5\" ry=\"8.5\" fill=\"$3\"/><path d=\"M0 -6l1 -4\" stroke=\"#2EAD4B\" stroke-width=\"2.5\" stroke-linecap=\"round\"/></g>"; }
{ head
 bat 70 90 1.6 "#8E44AD"; ghost 410 120 1.5 "#E8E8F0"; bat 380 390 1.3 "#8E44AD"; ghost 90 400 1.4 "#E8E8F0"
 bat 250 70 1.1 "#8E44AD"; ghost 40 250 1.2 "#E8E8F0"; bat 445 280 1.2 "#8E44AD"; ghost 300 440 1.1 "#E8E8F0"
 echo '<text x="240" y="230" fill="#FFF" font-size="120" font-weight="200" text-anchor="middle">9:41</text><text x="240" y="280" fill="#FFF" fill-opacity=".7" font-size="20" font-weight="600" text-anchor="middle">Tuesday, October 13</text>'
 pumpkin 119 323 "#FF7518"; echo '<text x="138" y="330" fill="#FFF" font-size="20" font-weight="600">18 days until Halloween</text>'; foot; } > $O/holiday.svg

# ── Sleep screen note: a birthday, with now playing underneath ─────────────
cake() { # cx cy color
  echo "<g transform=\"translate($1 $2)\" fill=\"$3\"><rect x=\"-9\" y=\"-1\" width=\"18\" height=\"10\" rx=\"2\"/><rect x=\"-1.2\" y=\"-8\" width=\"2.4\" height=\"6\"/><path d=\"M0 -13c2 2 2 4 0 4s-2 -2 0 -4z\"/></g>"; }
{ head; echo '<text x="240" y="215" fill="#FFF" font-size="120" font-weight="200" text-anchor="middle">7:05</text><text x="240" y="265" fill="#FFF" fill-opacity=".7" font-size="20" font-weight="600" text-anchor="middle">Saturday, March 14</text>'
 cake 135 309 "#FFF"; echo '<text x="154" y="316" fill="#FFF" font-size="20" font-weight="600">Happy birthday, Emma!</text>'
 echo '<text x="240" y="356" fill="#FFF" fill-opacity=".5" font-size="16" font-weight="500" text-anchor="middle">Still Out There Running · Nathaniel Rateliff</text>'; foot; } > $O/sleep-note.svg

# ── Settings → Voice (panels with voice) ────────────────────────────────────
{ head; hdr Settings
 sec 32 92 VOICE; echo '<rect x="16" y="102" width="448" height="216" rx="14" fill="#1C1C1E"/>'
 echo '<text x="32" y="135" fill="#FFF" font-size="16">Wake word</text><rect x="220" y="111" width="232" height="36" rx="10" fill="#2C2C2E"/><rect x="222" y="113" width="113" height="32" rx="8" fill="#636366"/><text x="278" y="135" fill="#FFF" font-size="16" text-anchor="middle">Okay Nabu</text><text x="393" y="135" fill="#FFF" font-size="16" text-anchor="middle">Hey Jarvis</text>'
 echo '<rect x="32" y="156" width="432" height="1" fill="#38383A"/><text x="32" y="189" fill="#FFF" font-size="16">Mute wake word</text><rect x="396" y="168" width="52" height="30" rx="15" fill="#39393D"/><circle cx="411" cy="183" r="12" fill="#FFF"/>'
 echo '<rect x="32" y="210" width="432" height="1" fill="#38383A"/><text x="32" y="243" fill="#FFF" font-size="16">Reply volume</text><text x="448" y="243" fill="#8E8E93" font-size="16" text-anchor="end">60%</text>'
 echo '<rect x="32" y="260" width="416" height="44" rx="14" fill="#2C2C2E"/><rect x="32" y="260" width="250" height="44" rx="14" fill="#F2F2F7"/>'
 sec 32 356 "ABOUT THIS PROJECT"; echo '<rect x="16" y="366" width="448" height="114" fill="#1C1C1E"/><rect x="16" y="366" width="448" height="30" rx="14" fill="#1C1C1E"/><text x="32" y="406" fill="#FFF" font-size="20" font-weight="600">esphome-lvgl-panel</text><text x="32" y="430" fill="#8E8E93" font-size="13">https://github.com/gjsiii/esphome-lvgl-panel</text>'
 foot; } > $O/voice-settings.svg

# ── About (bottom of Settings) ──────────────────────────────────────────────
{ head; hdr Settings
 echo '<rect x="16" y="70" width="448" height="96" rx="14" fill="#1C1C1E"/><text x="32" y="102" fill="#FFF" font-size="16">Uptime</text><text x="448" y="102" fill="#8E8E93" font-size="16" text-anchor="end">3d 4h 12m</text><rect x="32" y="118" width="416" height="1" fill="#38383A"/><text x="32" y="146" fill="#FFF" font-size="16">Last restart</text><text x="448" y="146" fill="#8E8E93" font-size="16" text-anchor="end">Software</text>'
 echo '<rect x="16" y="180" width="448" height="50" rx="14" fill="#1C1C1E"/><text x="240" y="211" fill="#FF453A" font-size="16" text-anchor="middle">Hold to restart</text>'
 sec 32 268 "ABOUT THIS PROJECT"; echo '<rect x="16" y="282" width="448" height="176" rx="14" fill="#1C1C1E"/><rect x="32" y="298" width="144" height="144" rx="8" fill="#FFF"/>'
 RANDOM=7; q=""; for r in $(seq 0 24); do for c in $(seq 0 24); do
   inf=0; for o in "0 0" "0 18" "18 0"; do set -- $o; [ $r -ge $1 ] && [ $r -lt $(( $1 + 7 )) ] && [ $c -ge $2 ] && [ $c -lt $(( $2 + 7 )) ] && inf=1; done
   [ $inf = 1 ] && continue; [ $((RANDOM % 2)) -eq 1 ] && q="$q<rect x=\"$((42 + c*5))\" y=\"$((308 + r*5))\" width=\"5\" height=\"5\"/>"; done; done
 fp() { echo "<rect x=\"$1\" y=\"$2\" width=\"35\" height=\"35\" fill=\"#000\"/><rect x=\"$(( $1 + 5 ))\" y=\"$(( $2 + 5 ))\" width=\"25\" height=\"25\" fill=\"#FFF\"/><rect x=\"$(( $1 + 10 ))\" y=\"$(( $2 + 10 ))\" width=\"15\" height=\"15\" fill=\"#000\"/>"; }
 echo "<g fill=\"#000\">$q</g>"; fp 42 308; fp 132 308; fp 42 398
 echo '<text x="192" y="320" fill="#FFF" font-size="20" font-weight="600">esphome-lvgl-panel</text><text x="192" y="342" fill="#8E8E93" font-size="13">https://github.com/gjsiii/</text><text x="192" y="358" fill="#8E8E93" font-size="13">esphome-lvgl-panel</text>'
 echo '<text x="192" y="386" fill="#8E8E93" font-size="13">Scan for the code, setup guides</text><text x="192" y="402" fill="#8E8E93" font-size="13">and updates.</text><text x="192" y="434" fill="#30D158" font-size="13" font-weight="500">Version 0.4.0  ·  v0.5.0 available</text>'
 foot; } > $O/about.svg
