#!/bin/bash
# VasoLog - снять 4 скриншота для каждого из 18 языков
# Предусловие: приложение открыто (можно на любом экране)
# Запуск: bash scripts/shoot_all_langs.sh

set -e

ADB="${ADB:-/d/dev/AndroidSDK/platform-tools/adb.exe}"
OUT="/d/DEV/vasolog/release/v1.1.0/store_assets/appgallery/raw"

# ── helpers ──────────────────────────────────────────────────────────────────

tap() { "$ADB" shell input tap "$1" "$2"; sleep "${3:-1.5}"; }
back() { "$ADB" shell input keyevent 4; sleep 1.2; }
shot() { "$ADB" exec-out screencap -p > "$1"; echo "    OK: $(basename $1)"; }

# Калибровано: Системный=0 → actual y=419, шаг=194px
lang_y() {
  local idx=$1
  echo $(( 419 + idx * 194 ))
}

# Навигация по bottom tabs (y=2650)
go_home()    { tap 157  2650; }
go_history() { tap 472  2650; }
go_report()  { tap 787  2650; }
go_info()    { tap 1050 2650; }

# Открыть language picker из любого места
open_lang_picker() {
  go_info
  sleep 0.5
  tap 630 1050   # Settings row
  tap 630 412    # Language row
  sleep 1
}

# Пролистать picker к началу (свайп вниз - возврат к началу)
scroll_picker_top() {
  "$ADB" shell input swipe 630 400 630 2400 500
  sleep 0.8
}

# Пролистать picker вниз на px
scroll_picker_down() {
  local px=$1
  "$ADB" shell input swipe 630 1800 630 $(( 1800 - px )) 300
  sleep 0.8
}

# Выбрать язык по индексу в списке (0=Системный, 1=English, ...)
# Для элементов 12+: нужна прокрутка вниз на 1400px, затем пересчёт y
select_lang() {
  local idx=$1
  scroll_picker_top

  local y
  if (( idx <= 11 )); then
    # Items 0-11: видимы без прокрутки
    y=$(( 419 + idx * 194 ))
    tap 630 $y 2.5
  else
    # Items 12-18: прокрутить вниз на 1400px (контент ~4000px, экран ~2400px)
    scroll_picker_down 1400
    sleep 0.5
    # После scroll 1400px: item i был на y=419+i*194, стал на y=419+i*194-1400
    y=$(( 419 + idx * 194 - 1400 ))
    tap 630 $y 2.5
  fi
}

# Снять 4 экрана для текущего языка (app уже на home после смены языка)
shoot_lang() {
  local code=$1
  local dir="$OUT/$code"
  mkdir -p "$dir"

  # 1. Home
  go_home
  sleep 1
  shot "$dir/01_home.png"

  # 2. Add episode (FAB)
  tap 630 2530 2
  shot "$dir/02_add_episode.png"
  back

  # 3. History
  go_history
  sleep 1
  shot "$dir/03_history.png"

  # 4. Report
  go_report
  sleep 1
  shot "$dir/04_report.png"
}

# ── Список языков (код, индекс в picker) ─────────────────────────────────────
# 0=Системный, 1=English, 2=Русский, 3=Deutsch, 4=Français, 5=Español,
# 6=Português, 7=Italiano, 8=Svenska, 9=Suomi, 10=Norsk, 11=Dansk,
# 12=Nederlands, 13=Polski, 14=Čeština, 15=Magyar, 16=Українська,
# 17=日本語, 18=한국어

declare -A LANGS=(
  [ru]=2  [de]=3  [fr]=4  [es]=5  [pt]=6
  [it]=7  [sv]=8  [fi]=9  [nb]=10 [da]=11
  [nl]=12 [pl]=13 [cs]=14 [hu]=15 [uk]=16
  [ja]=17 [ko]=18
)

# ── Main ─────────────────────────────────────────────────────────────────────

echo "=== VasoLog AppGallery Screenshots ==="
echo "Output: $OUT"

# English уже снят — пропускаем
echo ""
echo "[0/17] en — уже снят, пропуск"

# Открыть picker для первого языка (ru)
echo ""
echo "Открываю language picker..."
open_lang_picker

TOTAL=${#LANGS[@]}
i=0
for code in ru de fr es pt it sv fi nb da nl pl cs hu uk ja ko; do
  idx=${LANGS[$code]}
  i=$(( i + 1 ))
  echo ""
  echo "[$i/$TOTAL] $code (picker index $idx)"

  select_lang $idx
  echo "  Язык применён, жду..."
  sleep 2

  shoot_lang "$code"

  # Открыть picker для следующего языка (кроме последнего)
  if (( i < TOTAL )); then
    echo "  Возвращаюсь к picker..."
    open_lang_picker
  fi
done

echo ""
echo "=== ГОТОВО: $TOTAL языков × 4 экрана ==="
echo "Файлы: $OUT"
