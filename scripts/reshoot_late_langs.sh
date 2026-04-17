#!/bin/bash
# Пересъёмка языков idx >= 11 с корректным offset (реальный scroll = -1594px, не 1400).
# Запускать когда app на любой локали - скрипт сам переключит.
set -e

ADB="${ADB:-/d/dev/AndroidSDK/platform-tools/adb.exe}"
OUT="/d/DEV/vasolog/release/v1.1.0/store_assets/appgallery/raw"

tap() { "$ADB" shell input tap "$1" "$2"; sleep "${3:-1.5}"; }
shot() { "$ADB" exec-out screencap -p > "$1"; echo "  OK: $(basename $1)"; }

go_home()    { tap 157  2650; }
go_history() { tap 472  2650; }
go_report()  { tap 787  2650; }
go_info()    { tap 1050 2650; }

open_lang_picker() {
  go_info; sleep 0.5
  tap 630 1050   # Settings row
  tap 630 412    # Language row
  sleep 1
}

scroll_picker_top() {
  "$ADB" shell input swipe 630 400 630 2400 500
  sleep 1
}

scroll_picker_down() {
  "$ADB" shell input swipe 630 1800 630 $(( 1800 - $1 )) 300
  sleep 1
}

# Калибровка: после swipe 1800->200 реальный сдвиг ~1600 (600 speed, bouncing).
# Для idx >= 11 используем меньший scroll чтобы item попал в видимую зону и tap'ался по правильному y.
select_lang() {
  local idx=$1
  scroll_picker_top
  if (( idx <= 10 )); then
    local y=$(( 419 + idx * 194 ))
    tap 630 $y 2.5
  else
    # Scroll на фикс. 1600 px (с inertia бывает чуть больше)
    "$ADB" shell input swipe 630 2000 630 400 600
    sleep 1.5
    # После scroll 1600: idx i на y = 419 + i*194 - 1600
    local y=$(( 419 + idx * 194 - 1600 ))
    tap 630 $y 2.5
  fi
}

shoot_lang() {
  local code=$1
  local dir="$OUT/$code"
  mkdir -p "$dir"
  go_home; sleep 1
  shot "$dir/01_home.png"
  tap 630 2530 2
  shot "$dir/02_add_episode.png"
  "$ADB" shell input keyevent 4; sleep 1
  go_history; sleep 1
  shot "$dir/03_history.png"
  go_report; sleep 1
  shot "$dir/04_report.png"
}

# Только идентификаторы 11..18 (da..ko)
declare -A LANGS=(
  [da]=11 [nl]=12 [pl]=13 [cs]=14 [hu]=15 [uk]=16 [ja]=17 [ko]=18
)

echo "=== Reshooting 8 languages ==="
# Первый открыть picker из текущего состояния
open_lang_picker

i=0
TOTAL=${#LANGS[@]}
for code in da nl pl cs hu uk ja ko; do
  idx=${LANGS[$code]}
  i=$(( i + 1 ))
  echo ""
  echo "[$i/$TOTAL] $code (idx $idx)"
  select_lang $idx
  sleep 2
  shoot_lang "$code"
  if (( i < TOTAL )); then
    open_lang_picker
  fi
done

echo ""
echo "=== DONE ==="
