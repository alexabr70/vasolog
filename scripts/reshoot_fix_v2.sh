#!/bin/bash
# Надёжный переснимщик битых языков VasoLog.
# Ключевые отличия от reshoot_late_langs.sh:
#   1. НЕ делает pm clear - язык сохраняется между запусками.
#   2. Перед каждым тапом проверяет mCurrentFocus = com.vasolog.app.
#   3. При сбое фокуса - авто-восстановление через monkey launch.
#   4. Проверяет после смены языка что вернулись в app (не в picker).
#   5. Инкрементальный scroll с sleep 0.5 между мелкими свайпами вместо 1 большого.
#
# Использование:
#   bash scripts/reshoot_fix_v2.sh            # все 8 битых языков
#   bash scripts/reshoot_fix_v2.sh da nl      # только указанные
#
# Предусловие: VasoLog открыт на home (не в picker, не в onboarding, не в settings).

set -e

ADB="${ADB:-/d/dev/AndroidSDK/platform-tools/adb.exe}"
OUT="/d/DEV/vasolog/release/v1.1.0/store_assets/appgallery/raw"
PKG="com.vasolog.app"

# Координаты калиброваны для Pixel-like 1260x2844 (см. shoot_all_langs.sh)
BOTTOM_Y=2650

# Bottom tabs
X_HOME=157
X_HISTORY=472
X_REPORT=787
X_INFO=1050

# Language picker:
# - из home: info tab -> Settings row (630,1050) -> Language row (630,412)
# - В picker: items начинаются с y=419, шаг 194px
SETTINGS_ROW_Y=1050
LANG_ROW_Y=412
PICKER_START_Y=419
PICKER_STEP=194
VISIBLE_MAX_IDX=10   # idx 0..10 видны без scroll

tap()   { "$ADB" shell input tap "$1" "$2"; sleep "${3:-1.5}"; }
back()  { "$ADB" shell input keyevent 4; sleep 1.0; }
swipe() { "$ADB" shell input swipe "$1" "$2" "$3" "$4" "${5:-300}"; sleep 0.8; }

# ── Проверки состояния ───────────────────────────────────────────────────────

is_vasolog_focused() {
  "$ADB" shell "dumpsys window | grep -E 'mCurrentFocus|mFocusedApp' | head -2" 2>/dev/null | grep -q "$PKG"
}

wait_for_vasolog() {
  local tries=${1:-10}
  for ((i=0; i<tries; i++)); do
    if is_vasolog_focused; then return 0; fi
    sleep 0.5
  done
  return 1
}

recover_to_vasolog() {
  echo "  [recover] launching $PKG"
  "$ADB" shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
  sleep 2
  wait_for_vasolog 10 || {
    echo "  [FATAL] cannot bring VasoLog to focus"
    return 1
  }
  # Закрыть возможные модалки/pickers через back (до 3 раз)
  for _ in 1 2 3; do
    back
    if is_vasolog_focused; then break; fi
  done
  return 0
}

ensure_vasolog() {
  if ! is_vasolog_focused; then
    echo "  [warn] focus lost - recovering"
    recover_to_vasolog || return 1
  fi
  return 0
}

# ── Шотинг ───────────────────────────────────────────────────────────────────

shot() {
  "$ADB" exec-out screencap -p > "$1"
  echo "  OK: $(basename "$1")"
}

# Навигация
go_home()    { ensure_vasolog; tap $X_HOME $BOTTOM_Y; }
go_history() { ensure_vasolog; tap $X_HISTORY $BOTTOM_Y; }
go_report()  { ensure_vasolog; tap $X_REPORT $BOTTOM_Y; }
go_info()    { ensure_vasolog; tap $X_INFO $BOTTOM_Y; }

# ── Language picker ──────────────────────────────────────────────────────────

open_lang_picker() {
  ensure_vasolog || return 1
  go_info; sleep 0.5
  tap 630 $SETTINGS_ROW_Y
  tap 630 $LANG_ROW_Y
  sleep 1
}

# Скроллим picker в самый верх: 3 маленьких свайпа вниз (контент вверх)
# Мелкими кусками надёжнее - меньше inertia misses.
scroll_picker_top() {
  for _ in 1 2 3; do
    swipe 630 400 630 2400 400
  done
  sleep 0.5
}

# Скроллим вниз на ~1600px через 2 средних свайпа (по 800px)
scroll_picker_down_2x800() {
  swipe 630 2200 630 1400 400
  swipe 630 2200 630 1400 400
  sleep 0.5
}

# Выбрать язык по idx. Калибровано для шага 194px.
# idx 0..10 - без скролла. idx 11..18 - один scroll_down_2x800, затем y -= 1600
select_lang() {
  local idx=$1
  scroll_picker_top
  local y
  if (( idx <= VISIBLE_MAX_IDX )); then
    y=$(( PICKER_START_Y + idx * PICKER_STEP ))
  else
    scroll_picker_down_2x800
    y=$(( PICKER_START_Y + idx * PICKER_STEP - 1600 ))
  fi
  tap 630 $y 2.5
  # После смены языка picker закрывается, возвращаемся в Settings или Info - ensure vasolog
  sleep 1
  ensure_vasolog || return 1
}

# ── 4 экрана для одного языка ────────────────────────────────────────────────

shoot_lang() {
  local code=$1
  local dir="$OUT/$code"
  mkdir -p "$dir"

  go_home; sleep 1.5
  ensure_vasolog || return 1
  shot "$dir/01_home.png"

  # FAB = кнопка добавить
  tap 630 2530 2
  ensure_vasolog || return 1
  shot "$dir/02_add_episode.png"
  back; sleep 0.5

  go_history; sleep 1.2
  ensure_vasolog || return 1
  shot "$dir/03_history.png"

  go_report; sleep 1.2
  ensure_vasolog || return 1
  shot "$dir/04_report.png"
}

# ── Основной список + аргументы ──────────────────────────────────────────────

declare -A LANG_IDX=(
  [en]=1  [ru]=2  [de]=3  [fr]=4  [es]=5  [pt]=6
  [it]=7  [sv]=8  [fi]=9  [nb]=10 [da]=11
  [nl]=12 [pl]=13 [cs]=14 [hu]=15 [uk]=16
  [ja]=17 [ko]=18
)

# Битые по умолчанию
DEFAULT_LANGS="da nl pl cs hu uk ja ko"

LANGS=${*:-$DEFAULT_LANGS}

echo "=== VasoLog Reshoot v2 ==="
echo "Languages: $LANGS"
echo "Output: $OUT"
echo ""

# Стартовая проверка
ensure_vasolog || {
  echo "FATAL: не удалось поднять VasoLog. Запусти приложение вручную и повтори."
  exit 1
}

TOTAL=$(echo "$LANGS" | wc -w)
i=0
for code in $LANGS; do
  idx=${LANG_IDX[$code]}
  if [[ -z "$idx" ]]; then
    echo "SKIP unknown language code: $code"
    continue
  fi
  i=$(( i + 1 ))
  echo ""
  echo "[$i/$TOTAL] $code (picker idx $idx)"
  open_lang_picker || { echo "  FAIL open_lang_picker"; continue; }
  select_lang "$idx" || { echo "  FAIL select_lang"; continue; }
  sleep 2
  shoot_lang "$code" || { echo "  FAIL shoot_lang"; continue; }
done

echo ""
echo "=== DONE ==="
