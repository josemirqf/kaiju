#!/bin/bash

# ============================================================
#   KAIJU NO. 8 - OPERATION: DEFENSE CORPS
#   Linux Text Adventure Game
#   v2.0 — Interactive menus & contextual hints
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
BOLD='\033[1m'
RESET='\033[0m'
BG_RED='\033[41m'
BG_BLACK='\033[40m'

declare -A INVENTORY
INVENTORY_LIST=()
CURRENT_LOCATION="defense_base"
CURRENT_ZONE="entrance"
GAME_ACTIVE=true
ENEMY_DEFEATED=false
KEY_ITEM_OBTAINED=false
STEPS=0
declare -A VISITED_ZONES

RANDOM_RESPONSES=(
    "⚠️  Kafka Hibino stares at you, confused: 'Is that a kaiju or a typo?'"
    "🐛  The Kaiju No. 8 inside you whispers: '...even I don't know what you meant.'"
    "📡  The percentile-92 suit AI doesn't recognize that. Use the menu numbers."
    "🔴  ALERT: Mina Ashiro is aiming at YOUR KEYBOARD. 'What was THAT?'"
    "💀  Mid-level kaijus are laughing at you from the shadows."
    "🎌  Soshiro Hoshina crosses his arms: 'That has zero tactical sense.'"
    "🌀  Percentile of that input: 0.0%. Pick a number from the menu."
    "🤖  Leno Ichikawa says: 'Not even the Corps manual covers what you just typed!'"
    "⚡  Reno Ichikawa looks for that command in the rulebook... it's not there."
    "🧠  Kikoru Shinomiya sighs deeply. 'Looks like someone skipped training.'"
    "🔫  UNKNOWN KAIJU DETECTED! Wait... it's just you typing weird stuff."
    "📻  Signal interrupted. Are you speaking kaiju language?"
    "💥  That input did more damage than a Level-9 Kaiju. To your game session."
    "🌊  The waves of Tachikawa Bay laugh at your attempt."
    "🏴  Director Isao Shinomiya raises an eyebrow: 'That is... unacceptable, soldier.'"
)

clear_screen() { clear; }
pause() { echo ""; echo -e "${GRAY}  [ Press ENTER to continue... ]${RESET}"; read -r; }

random_response() {
    local idx=$((RANDOM % ${#RANDOM_RESPONSES[@]}))
    echo -e "\n${YELLOW}  ${RANDOM_RESPONSES[$idx]}${RESET}"
    echo -e "${GRAY}  Choose a menu option by its number.${RESET}\n"
    sleep 1
}

sep()     { echo -e "${CYAN}  ══════════════════════════════════════════════════════${RESET}"; }
sep_red() { echo -e "${RED}  ══════════════════════════════════════════════════════${RESET}"; }
sep_mag() { echo -e "${MAGENTA}  ══════════════════════════════════════════════════════${RESET}"; }

has_item() { [[ "${INVENTORY[$1]}" == "true" ]]; }

add_to_inventory() {
    local item="$1"
    INVENTORY["$item"]=true
    INVENTORY_LIST+=("$item")
    echo ""
    echo -e "${GREEN}  ╔══════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}  ║  ✦ ITEM OBTAINED!                        ║${RESET}"
    echo -e "${GREEN}  ║  ${WHITE}${BOLD}$item${RESET}${GREEN}$(printf '%*s' $((42 - ${#item})) '')║${RESET}"
    echo -e "${GREEN}  ╚══════════════════════════════════════════╝${RESET}"
    sleep 1
}

status_bar() {
    echo -e "${BG_BLACK}${WHITE}  📍 $1 ${GRAY}› ${CYAN}$2   ${GRAY}🎒 Items: ${WHITE}${#INVENTORY_LIST[@]}  ${GRAY}👣 Steps: ${WHITE}$STEPS  ${RESET}"
}

declare -a MENU_ACTIONS

show_menu() {
    local title="$1"; shift
    local options=("$@")
    MENU_ACTIONS=()
    echo ""
    echo -e "${BOLD}${WHITE}  ┌─ $title ──────────────────────────────────────${RESET}"
    local i=1
    for option in "${options[@]}"; do
        local icon="${option%%|*}"
        local rest="${option#*|}"
        local text="${rest%%|*}"
        local action="${rest#*|}"
        local color="${CYAN}"
        if [[ "$action" == take_* ]]; then color="${YELLOW}"; fi
        if [[ "$action" == attack* ]]; then color="${RED}"; fi
        if [[ "$action" == go_loc_* ]]; then color="${BLUE}"; fi
        if [[ "$action" == go_zone_* ]]; then color="${WHITE}"; fi
        if [[ "$action" == inv* || "$action" == map* || "$action" == help* ]]; then color="${GRAY}"; fi
        echo -e "  ${BOLD}${WHITE}  $i)${RESET} $icon  ${color}$text${RESET}"
        MENU_ACTIONS+=("$action")
        ((i++))
    done
    echo -e "${BOLD}${WHITE}  └────────────────────────────────────────────────────${RESET}"
    echo ""
    echo -e -n "${BOLD}${GREEN}  HIBINO ▶ Choose [1-$((i-1))]: ${RESET}"
}

read_input() {
    read -r input
    input=$(echo "$input" | tr '[:upper:]' '[:lower:]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    STEPS=$((STEPS + 1))
}

process_selection() {
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        local idx=$((input - 1))
        if [[ $idx -ge 0 && $idx -lt ${#MENU_ACTIONS[@]} ]]; then
            run_action "${MENU_ACTIONS[$idx]}"
            return 0
        fi
    fi
    process_free_text "$input"
}

run_action() {
    local action="$1"
    case "$action" in
        go_loc_*)   CURRENT_LOCATION="${action#go_loc_}"; CURRENT_ZONE="" ;;
        go_zone_*)  CURRENT_ZONE="${action#go_zone_}"; VISITED_ZONES["$CURRENT_LOCATION:$CURRENT_ZONE"]=true ;;
        take_*)     _take_item "${action#take_}" ;;
        attack)     process_attack ;;
        inventory)  show_inventory ;;
        map)        show_map ;;
        help)       show_help ;;
        quit)       confirm_quit ;;
        _sep)       echo -e "${GRAY}  (that is just a visual separator)${RESET}"; sleep 1 ;;
        *)          random_response ;;
    esac
}

process_free_text() {
    local txt="$1"
    local cmd=$(echo "$txt" | awk '{print $1}')
    local arg=$(echo "$txt" | cut -d' ' -f2-)
    case "$cmd" in
        go|move|travel|walk)    _go_text "$arg" ;;
        take|grab|pick|get)     _take_text "$arg" ;;
        attack|fight|use)       process_attack ;;
        inventory|inv|bag|items) show_inventory ;;
        map|where|location)     show_map ;;
        help|"?"|commands)      show_help ;;
        quit|exit|leave|end)    confirm_quit ;;
        "")  ;;
        *)   random_response ;;
    esac
}

_go_text() {
    local dest="$1"
    case "$dest" in
        defense_base|tachikawa_city|contaminated_zone|elite_quarters|kaiju_lair)
            CURRENT_LOCATION="$dest"; CURRENT_ZONE="" ;;
        entrance|armory|hangar|market|hospital|rooftop|ruins|laboratory|crater|command_room|dojo|elite_arsenal|lair_entrance|deep_tunnel|kaiju_core)
            CURRENT_ZONE="$dest"; VISITED_ZONES["$CURRENT_LOCATION:$dest"]=true ;;
        *) echo -e "${YELLOW}  That place doesn't exist. Use the menu to navigate.${RESET}"; sleep 1 ;;
    esac
}

_take_text() {
    case "$1" in
        manual|handbook)  _take_item "manual" ;;
        rifle|gun)        _take_item "rifle" ;;
        armor|armour)     _take_item "armor" ;;
        potion|elixir)    _take_item "potion" ;;
        grenade)          _take_item "grenade" ;;
        kit|medkit|first) _take_item "medkit" ;;
        shield)           _take_item "shield" ;;
        essence|crystal)  _take_item "essence" ;;
        katana|sword)     _take_item "katana" ;;
        suit|outfit)      _take_item "suit" ;;
        *) echo -e "${YELLOW}  There's no '$1' here to pick up.${RESET}"; sleep 1 ;;
    esac
}

_take_item() {
    local item="$1"
    case "$CURRENT_LOCATION:$CURRENT_ZONE:$item" in
        defense_base:entrance:manual)
            has_item "Class-S Tactical Manual" && { echo -e "${GRAY}  You already have it.${RESET}"; sleep 1; } || add_to_inventory "Class-S Tactical Manual" ;;
        defense_base:armory:rifle)
            has_item "Anti-Kaiju Rifle Type-07" && { echo -e "${GRAY}  You already have it.${RESET}"; sleep 1; } || add_to_inventory "Anti-Kaiju Rifle Type-07" ;;
        defense_base:armory:armor)
            has_item "Corps Light Armor" && { echo -e "${GRAY}  You already have it.${RESET}"; sleep 1; } || add_to_inventory "Corps Light Armor" ;;
        tachikawa_city:market:potion)
            has_item "Kaiju Regeneration Potion" && { echo -e "${GRAY}  You already have it.${RESET}"; sleep 1; } || add_to_inventory "Kaiju Regeneration Potion" ;;
        tachikawa_city:market:grenade)
            has_item "Anti-Kaiju Sonic Grenade" && { echo -e "${GRAY}  You already have it.${RESET}"; sleep 1; } || add_to_inventory "Anti-Kaiju Sonic Grenade" ;;
        tachikawa_city:hospital:medkit)
            has_item "Corps Field Medkit" && { echo -e "${GRAY}  You already have it.${RESET}"; sleep 1; } || add_to_inventory "Corps Field Medkit" ;;
        contaminated_zone:ruins:shield)
            has_item "Anti-Corrosion Shield" && { echo -e "${GRAY}  You already have it.${RESET}"; sleep 1; } || add_to_inventory "Anti-Corrosion Shield" ;;
        contaminated_zone:laboratory:essence)
            if ! has_item "Crystallized Kaiju Essence"; then
                add_to_inventory "Crystallized Kaiju Essence"
                KEY_ITEM_OBTAINED=true
                echo -e "\n${BOLD}${YELLOW}  ★★★ KEY ITEM OBTAINED! ★★★${RESET}"
                echo -e "${WHITE}  You can now defeat Kaiju No. 9 at the Kaiju Lair!${RESET}"
                sleep 2
            else echo -e "${GRAY}  You already have it.${RESET}"; sleep 1; fi ;;
        elite_quarters:elite_arsenal:katana)
            has_item "Kaiju-Fiber Katana Type-X" && { echo -e "${GRAY}  You already have it.${RESET}"; sleep 1; } || add_to_inventory "Kaiju-Fiber Katana Type-X" ;;
        elite_quarters:elite_arsenal:suit)
            has_item "Reinforced Percentile-92 Suit" && { echo -e "${GRAY}  You already have it.${RESET}"; sleep 1; } || add_to_inventory "Reinforced Percentile-92 Suit" ;;
        *)
            echo -e "${YELLOW}  You can't take that here.${RESET}"; sleep 1 ;;
    esac
}

confirm_quit() {
    echo ""; echo -e "${YELLOW}  Are you sure you want to abandon the mission? (y/n)${RESET}"
    read -r confirm
    [[ "$confirm" == "y" || "$confirm" == "yes" ]] && { echo -e "${GRAY}  Mission abandoned. The Corps takes note.${RESET}"; GAME_ACTIVE=false; }
}

# ═══════════════════════════════════════════════════════════════
#   INVENTORY & MAP
# ═══════════════════════════════════════════════════════════════

show_inventory() {
    clear_screen; sep
    echo -e "${BOLD}${YELLOW}  ╔══ COMBAT INVENTORY ══╗${RESET}"; sep
    if [ ${#INVENTORY_LIST[@]} -eq 0 ]; then
        echo -e "${GRAY}  [ Empty — Explore to find items! ]${RESET}"
    else
        for item in "${INVENTORY_LIST[@]}"; do
            local ico="🔧"
            case "$item" in
                *Rifle*|*Katana*|*Grenade*) ico="⚔️ " ;;
                *Armor*|*Suit*|*Shield*)    ico="🛡️ " ;;
                *Potion*|*Medkit*)          ico="💊" ;;
                *Essence*)                  ico="⭐" ;;
                *Manual*)                   ico="📋" ;;
            esac
            echo -e "  ${GREEN}▸${RESET} $ico  ${WHITE}$item${RESET}"
        done
    fi
    sep
    if ! has_item "Crystallized Kaiju Essence"; then
        echo -e "${RED}  ⚠  OBJECTIVE: Get the Crystallized Kaiju Essence${RESET}"
        echo -e "${GRAY}     → Contaminated Zone › Abandoned Laboratory${RESET}"
    else
        echo -e "${GREEN}  ✓  READY: Go to Kaiju Lair › kaiju_core and attack!${RESET}"
    fi
    sep; pause
}

show_map() {
    clear_screen; sep
    echo -e "${BOLD}${BLUE}  ╔══ TACTICAL MAP — DEFENSE CORPS ══╗${RESET}"; sep; echo ""
    local locs=(
        "defense_base|🏢|Defense Corps Base        |entrance, armory, hangar"
        "tachikawa_city|🏙️ |City of Tachikawa         |market, hospital, rooftop"
        "contaminated_zone|☠️ |Northern Contaminated Zone |ruins, laboratory, crater"
        "elite_quarters|⚔️ |Elite Quarters             |command_room, dojo, elite_arsenal"
        "kaiju_lair|👹|Kaiju Final Lair           |lair_entrance, deep_tunnel, kaiju_core"
    )
    local i=1
    for e in "${locs[@]}"; do
        local id="${e%%|*}"; local r="${e#*|}"; local ico="${r%%|*}"; local r2="${r#*|}"; local nom="${r2%%|*}"; local zones="${r2#*|}"
        local mark=""; [[ "$CURRENT_LOCATION" == "$id" ]] && mark="${RED} ◀ YOU ARE HERE${RESET}"
        local col="${WHITE}"; [[ "$id" == "kaiju_lair" ]] && col="${RED}"
        echo -e "  ${CYAN}[$i]${RESET} $ico  ${col}${BOLD}$nom${RESET}$mark"
        echo -e "       ${GRAY}Zones: $zones${RESET}"; echo ""
        ((i++))
    done
    sep
    if ! has_item "Crystallized Kaiju Essence"; then
        echo -e "${YELLOW}  🎯 OBJECTIVE: Contaminated Zone › Laboratory › take essence${RESET}"
    else
        echo -e "${GREEN}  🎯 OBJECTIVE: Kaiju Lair › kaiju_core › attack${RESET}"
    fi
    sep; pause
}

show_help() {
    clear_screen; sep
    echo -e "${BOLD}${YELLOW}  ╔══ QUICK MANUAL ══╗${RESET}"; sep; echo ""
    echo -e "${WHITE}  The game shows a numbered menu at every zone.${RESET}"
    echo -e "${CYAN}  Just type the number of the option you want.${RESET}"; echo ""
    echo -e "${BOLD}  Menu colors:${RESET}"
    echo -e "  ${YELLOW}  Yellow${RESET}  → Pick up an item"
    echo -e "  ${WHITE}  White${RESET}   → Move to a zone"
    echo -e "  ${BLUE}  Blue${RESET}    → Travel to another location"
    echo -e "  ${RED}  Red${RESET}     → Combat action"
    echo -e "  ${GRAY}  Gray${RESET}    → Inventory / map / help"; echo ""
    echo -e "${BOLD}  You can also type:${RESET}"
    echo -e "  ${CYAN}  inventory${RESET}  — View your items    ${CYAN}  map${RESET}  — See the map"
    echo -e "  ${CYAN}  help${RESET}       — This manual         ${CYAN}  quit${RESET} — End game"; echo ""
    sep
    echo -e "${YELLOW}  🎯 MISSION: Contaminated Zone → Laboratory → take essence${RESET}"
    echo -e "${YELLOW}     then Kaiju Lair → kaiju_core → attack${RESET}"
    sep; pause
}

# ═══════════════════════════════════════════════════════════════
#   TITLE SCREEN
# ═══════════════════════════════════════════════════════════════

title_screen() {
    clear_screen
    echo -e "${BG_BLACK}${RED}"
    cat << 'TITLE_ASCII'

  ██╗  ██╗ █████╗ ██╗      ██╗██╗   ██╗    ███╗   ██╗ ██████╗      █████╗
  ██║ ██╔╝██╔══██╗██║      ██║██║   ██║    ████╗  ██║██╔═══██╗    ██╔══██╗
  █████╔╝ ███████║██║      ██║██║   ██║    ██╔██╗ ██║██║   ██║    ╚█████╔╝
  ██╔═██╗ ██╔══██║██║      ██║██║   ██║    ██║╚██╗██║██║   ██║    ██╔══██╗
  ██║  ██╗██║  ██║███████╗ ██║╚██████╔╝    ██║ ╚████║╚██████╔╝    ╚█████╔╝
  ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ╚═╝ ╚═════╝     ╚═╝  ╚═══╝ ╚═════╝      ╚════╝

TITLE_ASCII
    echo -e "${RESET}"
    echo -e "${BOLD}${WHITE}          ╔══ OPERATION: DEFENSE CORPS — v2.0 ══╗${RESET}"
    echo -e "${GRAY}               Interactive Text Adventure for Linux${RESET}"
    echo ""
    sep
    echo -e "${YELLOW}  You are Kafka Hibino, soldier of the Defense Corps.${RESET}"
    echo -e "${WHITE}  An unknown-level kaiju threatens the city of Tachikawa.${RESET}"
    echo -e "${CYAN}  → Choose menu options by typing their number.${RESET}"
    sep
    echo ""; echo -e "${GRAY}  Press ENTER to begin the mission...${RESET}"
    read -r
}

# ═══════════════════════════════════════════════════════════════
#   LOCATION 1: DEFENSE CORPS BASE
# ═══════════════════════════════════════════════════════════════

loc_defense_base() {
    clear_screen
    status_bar "Defense Corps Base" "Select a zone"
    sep
    echo -e "${BOLD}${BLUE}  🏢  DEFENSE CORPS BASE${RESET}"; sep
    echo -e "${WHITE}  The Central Base stretches before you.${RESET}"
    echo -e "${GRAY}  Soldiers rush around. Alarms are silent... for now.${RESET}"
    show_menu "WHICH ZONE DO YOU GO TO?" \
        "🚪|Entrance — Registration hall|go_zone_entrance" \
        "🔫|Armory — Corps weapons storage|go_zone_armory" \
        "✈️ |Hangar — Tactical deployment (Leno's hint)|go_zone_hangar" \
        "🏙️ |Travel → City of Tachikawa|go_loc_tachikawa_city" \
        "☠️ |Travel → Northern Contaminated Zone|go_loc_contaminated_zone" \
        "⚔️ |Travel → Elite Quarters|go_loc_elite_quarters" \
        "👹|Travel → Kaiju Final Lair|go_loc_kaiju_lair" \
        "🎒|View inventory|inventory" \
        "🗺️ |View tactical map|map"
    read_input; process_selection
}

zone_base_entrance() {
    clear_screen
    status_bar "Defense Corps Base" "Main Entrance"
    sep_red
    echo -e "${BOLD}${BLUE}  🚪  DEFENSE CORPS BASE — MAIN ENTRANCE${RESET}"; sep_red
    cat << 'ASCII_BASE'

       ___________________________________________
      |   DEFENSE CORPS — AUTHORIZED ACCESS      |
      |___________________________________________|
      |  [GUARD]      [REGISTER]    [LOCKERS]    |
      |     👮            📋            🗄️        |
      |___________________________________________|
      |  ████████████████████████████████████    |
      |  █  WELCOME, SOLDIER HIBINO          █    |
      |  █  CURRENT THREAT LEVEL: RED        █    |
      |  ████████████████████████████████████    |
      |__________________________________________|

ASCII_BASE
    echo -e "${GRAY}  💬 Guard: 'Kaiju detected to the north. Get ready, soldier.'${RESET}"
    echo -e "${CYAN}  Something shines on the registration desk...${RESET}"
    local opc=()
    if ! has_item "Class-S Tactical Manual"; then
        opc+=("📋|Take the Class-S Tactical Manual ★|take_manual")
    else echo -e "${GREEN}  ✓ Class-S Tactical Manual — Already obtained.${RESET}"; fi
    opc+=("🔫|Go to the Armory|go_zone_armory")
    opc+=("✈️ |Go to the Hangar|go_zone_hangar")
    opc+=("🔙|Back to Defense Corps Base|go_loc_defense_base")
    opc+=("🎒|View inventory|inventory")
    show_menu "WHAT DO YOU DO?" "${opc[@]}"; read_input; process_selection
}

zone_base_armory() {
    clear_screen
    status_bar "Defense Corps Base" "Armory"
    sep_red
    echo -e "${BOLD}${BLUE}  🔫  DEFENSE CORPS BASE — ARMORY${RESET}"; sep_red
    echo ""
    echo -e "${WHITE}  Racks of anti-kaiju weapons line the walls floor to ceiling.${RESET}"; echo ""
    local opc=()
    if ! has_item "Anti-Kaiju Rifle Type-07"; then
        echo -e "${YELLOW}  ★ ${WHITE}Anti-Kaiju Rifle Type-07${YELLOW} on the main rack.${RESET}"
        opc+=("⚔️ |Take Anti-Kaiju Rifle Type-07|take_rifle")
    else echo -e "${GREEN}  ✓ Anti-Kaiju Rifle Type-07 — Already equipped.${RESET}"; fi
    if ! has_item "Corps Light Armor"; then
        echo -e "${YELLOW}  ★ ${WHITE}Corps Light Armor${YELLOW} on the workbench.${RESET}"
        opc+=("🛡️ |Take Corps Light Armor|take_armor")
    else echo -e "${GREEN}  ✓ Corps Light Armor — Already equipped.${RESET}"; fi
    opc+=("🚪|Go to the Entrance|go_zone_entrance")
    opc+=("✈️ |Go to the Hangar|go_zone_hangar")
    opc+=("🔙|Back to Defense Corps Base|go_loc_defense_base")
    opc+=("🎒|View inventory|inventory")
    show_menu "WHAT DO YOU DO?" "${opc[@]}"; read_input; process_selection
}

zone_base_hangar() {
    clear_screen
    status_bar "Defense Corps Base" "Deployment Hangar"
    sep_red
    echo -e "${BOLD}${BLUE}  ✈️   DEFENSE CORPS BASE — HANGAR${RESET}"; sep_red
    echo ""
    echo -e "${WHITE}  Corps transport aircraft fill the hangar.${RESET}"
    echo -e "${MAGENTA}  💬 Leno Ichikawa: 'Kafka, listen. For the northern kaiju you need${RESET}"
    echo -e "${BOLD}${YELLOW}  the Crystallized Kaiju Essence${RESET}${MAGENTA}. It's in the Contaminated Zone.'${RESET}"
    echo ""
    echo -e "${CYAN}  💡 HINT: Go to Contaminated Zone → Laboratory${RESET}"
    show_menu "WHAT DO YOU DO?" \
        "☠️ |Travel → Contaminated Zone (find the Essence)|go_loc_contaminated_zone" \
        "🚪|Go to the Entrance|go_zone_entrance" \
        "🔫|Go to the Armory|go_zone_armory" \
        "🔙|Back to Defense Corps Base|go_loc_defense_base" \
        "🎒|View inventory|inventory" \
        "🗺️ |View tactical map|map"
    read_input; process_selection
}

# ═══════════════════════════════════════════════════════════════
#   LOCATION 2: CITY OF TACHIKAWA
# ═══════════════════════════════════════════════════════════════

loc_tachikawa_city() {
    clear_screen
    status_bar "City of Tachikawa" "Select a zone"
    sep
    echo -e "${BOLD}${CYAN}  🏙️  CITY OF TACHIKAWA${RESET}"; sep
    echo -e "${WHITE}  Streets half-deserted under the kaiju alert.${RESET}"
    echo -e "${GRAY}  Civilians running. Some stare at the sky in fear.${RESET}"
    show_menu "WHICH ZONE DO YOU GO TO?" \
        "🛒|Black market — Supplies|go_zone_market" \
        "🏥|Emergency hospital|go_zone_hospital" \
        "🌆|Rooftop — Panoramic view|go_zone_rooftop" \
        "🏢|Travel → Defense Corps Base|go_loc_defense_base" \
        "☠️ |Travel → Northern Contaminated Zone|go_loc_contaminated_zone" \
        "⚔️ |Travel → Elite Quarters|go_loc_elite_quarters" \
        "👹|Travel → Kaiju Final Lair|go_loc_kaiju_lair" \
        "🎒|View inventory|inventory" \
        "🗺️ |View tactical map|map"
    read_input; process_selection
}

zone_city_market() {
    clear_screen
    status_bar "City of Tachikawa" "Black Market"
    sep
    echo -e "${BOLD}${CYAN}  🛒  TACHIKAWA CITY — BLACK MARKET${RESET}"; sep
    echo ""
    echo -e "${WHITE}  A hooded vendor whispers from a dark alley.${RESET}"
    echo -e "${GRAY}  'Psst... I've got things the Corps doesn't know about.'${RESET}"; echo ""
    local opc=()
    if ! has_item "Kaiju Regeneration Potion"; then
        echo -e "${YELLOW}  ★ ${WHITE}Kaiju Regeneration Potion${YELLOW} (free for Corps soldiers)${RESET}"
        opc+=("💊|Take Kaiju Regeneration Potion|take_potion")
    else echo -e "${GREEN}  ✓ Kaiju Regeneration Potion — Already obtained.${RESET}"; fi
    if ! has_item "Anti-Kaiju Sonic Grenade"; then
        echo -e "${YELLOW}  ★ ${WHITE}Anti-Kaiju Sonic Grenade${RESET}"
        opc+=("💣|Take Anti-Kaiju Sonic Grenade|take_grenade")
    else echo -e "${GREEN}  ✓ Anti-Kaiju Sonic Grenade — Already obtained.${RESET}"; fi
    opc+=("🏥|Go to the Hospital|go_zone_hospital")
    opc+=("🌆|Go to the Rooftop|go_zone_rooftop")
    opc+=("🔙|Back to Tachikawa City|go_loc_tachikawa_city")
    opc+=("🎒|View inventory|inventory")
    show_menu "WHAT DO YOU DO?" "${opc[@]}"; read_input; process_selection
}

zone_city_hospital() {
    clear_screen
    status_bar "City of Tachikawa" "Emergency Hospital"
    sep
    echo -e "${BOLD}${CYAN}  🏥  TACHIKAWA CITY — HOSPITAL${RESET}"; sep
    echo ""
    echo -e "${WHITE}  Kaiju attack victims fill the stretchers.${RESET}"
    echo -e "${MAGENTA}  💬 Doctor: 'That kaiju's core can only be destroyed with${RESET}"
    echo -e "${BOLD}${YELLOW}  the Crystallized Kaiju Essence${RESET}${MAGENTA}.'${RESET}"
    echo ""
    echo -e "${CYAN}  💡 CONFIRMED HINT: You need the Crystallized Essence.${RESET}"
    local opc=()
    if ! has_item "Corps Field Medkit"; then
        opc+=("💊|Take Corps Field Medkit|take_medkit")
    else echo -e "${GREEN}  ✓ Corps Field Medkit — Already obtained.${RESET}"; fi
    opc+=("☠️ |Travel → Contaminated Zone (has the Essence)|go_loc_contaminated_zone")
    opc+=("🛒|Go to the Market|go_zone_market")
    opc+=("🌆|Go to the Rooftop|go_zone_rooftop")
    opc+=("🔙|Back to Tachikawa City|go_loc_tachikawa_city")
    opc+=("🎒|View inventory|inventory")
    show_menu "WHAT DO YOU DO?" "${opc[@]}"; read_input; process_selection
}

zone_city_rooftop() {
    clear_screen
    status_bar "City of Tachikawa" "Rooftop"
    sep
    echo -e "${BOLD}${CYAN}  🌆  TACHIKAWA CITY — ROOFTOP${RESET}"; sep
    cat << 'ASCII_CITY'

        🏙️  TACHIKAWA — PANORAMIC VIEW  🏙️
       ______________________________________
      |  🏢  🏢  🏢     ⚠️      🏢  🏢  🏢  |
      |  ||||  ||||  ||||     ||||  ||||    |
      |  ||||  ||||  ||||     ||||  ||||    |
      |__________________🌆________________|
          ↑ NORTH: Kaiju signal detected
       ___↓_________________________________
      | COORD: 35°N / 139°E  ALERT ACTIVE  |
      |_____________________________________|

ASCII_CITY
    echo -e "${RED}  To the north, a dark threatening cloud. The kaiju is there.${RESET}"
    show_menu "WHAT DO YOU DO?" \
        "☠️ |Travel → Northern Contaminated Zone (kaiju to the north)|go_loc_contaminated_zone" \
        "🛒|Go to the Market|go_zone_market" \
        "🏥|Go to the Hospital|go_zone_hospital" \
        "🔙|Back to Tachikawa City|go_loc_tachikawa_city" \
        "🎒|View inventory|inventory"
    read_input; process_selection
}

# ═══════════════════════════════════════════════════════════════
#   LOCATION 3: NORTHERN CONTAMINATED ZONE
# ═══════════════════════════════════════════════════════════════

loc_contaminated_zone() {
    clear_screen
    status_bar "Northern Contaminated Zone" "Select a zone"
    sep_red
    echo -e "${BOLD}${RED}  ☠️   NORTHERN CONTAMINATED ZONE${RESET}"; sep_red
    echo -e "${WHITE}  Ground covered in viscous violet substance.${RESET}"
    echo -e "${RED}  Remains of defeated kaijus fill the horizon.${RESET}"
    echo ""
    if ! has_item "Crystallized Kaiju Essence"; then
        echo -e "${BOLD}${YELLOW}  💡 OBJECTIVE HERE: The Essence is in the Laboratory.${RESET}"
    else
        echo -e "${GREEN}  ✓ You have the Essence. Head to the Kaiju Lair.${RESET}"
    fi
    show_menu "WHICH ZONE DO YOU GO TO?" \
        "🏚️ |Ruins — Anti-Corrosion Shield|go_zone_ruins" \
        "🧪|Abandoned Laboratory ★ THE ESSENCE IS HERE|go_zone_laboratory" \
        "💀|Central kaiju impact crater|go_zone_crater" \
        "🏢|Travel → Defense Corps Base|go_loc_defense_base" \
        "🏙️ |Travel → City of Tachikawa|go_loc_tachikawa_city" \
        "⚔️ |Travel → Elite Quarters|go_loc_elite_quarters" \
        "👹|Travel → Kaiju Final Lair|go_loc_kaiju_lair" \
        "🎒|View inventory|inventory" \
        "🗺️ |View tactical map|map"
    read_input; process_selection
}

zone_contaminated_ruins() {
    clear_screen
    status_bar "Northern Contaminated Zone" "Ruins"
    sep_red
    echo -e "${BOLD}${RED}  🏚️   CONTAMINATED ZONE — RUINS${RESET}"; sep_red
    echo ""
    echo -e "${WHITE}  Collapsed buildings and rubble everywhere.${RESET}"
    echo -e "${YELLOW}  Among the debris, something glows with intense blue light...${RESET}"; echo ""
    local opc=()
    if ! has_item "Anti-Corrosion Shield"; then
        opc+=("🛡️ |Take Anti-Corrosion Shield|take_shield")
    else echo -e "${GREEN}  ✓ Anti-Corrosion Shield — Already obtained.${RESET}"; fi
    opc+=("🧪|Go to the Laboratory (has the Essence ★)|go_zone_laboratory")
    opc+=("💀|Go to the Crater|go_zone_crater")
    opc+=("🔙|Back to Contaminated Zone|go_loc_contaminated_zone")
    opc+=("🎒|View inventory|inventory")
    show_menu "WHAT DO YOU DO?" "${opc[@]}"; read_input; process_selection
}

zone_contaminated_laboratory() {
    clear_screen
    status_bar "Northern Contaminated Zone" "★ Abandoned Laboratory ★"
    sep_red
    echo -e "${BOLD}${RED}  🧪  CONTAMINATED ZONE — ABANDONED LABORATORY${RESET}"; sep_red
    echo ""
    echo -e "${WHITE}  Overturned tables, broken glass, abandoned experiments.${RESET}"
    echo ""
    echo -e "${BOLD}${YELLOW}  ╔═══════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${YELLOW}  ║  CRYSTALLIZED KAIJU ESSENCE          ║${RESET}"
    echo -e "${BOLD}${YELLOW}  ║  EXTREME DANGER — ELITE ACCESS ONLY  ║${RESET}"
    echo -e "${BOLD}${YELLOW}  ╚═══════════════════════════════════════╝${RESET}"
    echo ""
    local opc=()
    if ! has_item "Crystallized Kaiju Essence"; then
        echo -e "${RED}  ★ THE KEY ITEM TO WIN IS RIGHT HERE!${RESET}"
        opc+=("⭐|★ TAKE CRYSTALLIZED KAIJU ESSENCE ← NEEDED TO WIN|take_essence")
    else
        echo -e "${GREEN}  ✓ You have the Essence. Head to the Kaiju Lair and attack!${RESET}"
        opc+=("👹|Travel → Kaiju Final Lair (use the Essence there)|go_loc_kaiju_lair")
    fi
    opc+=("🏚️ |Go to the Ruins|go_zone_ruins")
    opc+=("💀|Go to the Crater|go_zone_crater")
    opc+=("🔙|Back to Contaminated Zone|go_loc_contaminated_zone")
    opc+=("🎒|View inventory|inventory")
    show_menu "WHAT DO YOU DO?" "${opc[@]}"; read_input; process_selection
}

zone_contaminated_crater() {
    clear_screen
    status_bar "Northern Contaminated Zone" "Central Crater"
    sep_red
    echo -e "${BOLD}${RED}  💀  CONTAMINATED ZONE — CENTRAL CRATER${RESET}"; sep_red
    cat << 'ASCII_CRATER'

          💀  KAIJU IMPACT ZONE  💀
         _________________________________
        /  ~~~~~~~~~~~~~~~~~~~~~~~~~~~    \
       /  ~  ☠  ☠  ☠  ☠  ☠  ☠  ☠  ~    \
      |   ~  ☠  [DESTROYED CORE]  ☠  ~   |
      |   ~  ☠  ☠  ☠  ☠  ☠  ☠  ☠  ~    |
       \  ~~~~~~~~~~~~~~~~~~~~~~~~~~~    /
        \_________________________________/
              ▲ RADIUS: 500 METERS ▲
           KAIJU RADIATION ACTIVE!

ASCII_CRATER
    echo -e "${WHITE}  A kaiju fell here months ago. Kaiju energy still active.${RESET}"
    echo -e "${GRAY}  You feel something inside you responding to this energy...${RESET}"
    show_menu "WHAT DO YOU DO?" \
        "🧪|Go to the Laboratory (has the Crystallized Essence ★)|go_zone_laboratory" \
        "🏚️ |Go to the Ruins|go_zone_ruins" \
        "🔙|Back to Contaminated Zone|go_loc_contaminated_zone" \
        "🎒|View inventory|inventory"
    read_input; process_selection
}

# ═══════════════════════════════════════════════════════════════
#   LOCATION 4: ELITE QUARTERS
# ═══════════════════════════════════════════════════════════════

loc_elite_quarters() {
    clear_screen
    status_bar "Elite Quarters" "Select a zone"
    sep_mag
    echo -e "${BOLD}${MAGENTA}  ⚔️   ELITE QUARTERS${RESET}"; sep_mag
    echo -e "${WHITE}  Headquarters of the Corps' best soldiers.${RESET}"
    show_menu "WHICH ZONE DO YOU GO TO?" \
        "🎖️ |Command Room — Mina Ashiro's briefing|go_zone_command_room" \
        "🥋|Dojo — Combat training room|go_zone_dojo" \
        "⚔️ |Elite Arsenal — Exclusive weapons|go_zone_elite_arsenal" \
        "🏢|Travel → Defense Corps Base|go_loc_defense_base" \
        "🏙️ |Travel → City of Tachikawa|go_loc_tachikawa_city" \
        "☠️ |Travel → Northern Contaminated Zone|go_loc_contaminated_zone" \
        "👹|Travel → Kaiju Final Lair|go_loc_kaiju_lair" \
        "🎒|View inventory|inventory" \
        "🗺️ |View tactical map|map"
    read_input; process_selection
}

zone_elite_command_room() {
    clear_screen
    status_bar "Elite Quarters" "Command Room"
    sep_mag
    echo -e "${BOLD}${MAGENTA}  🎖️   ELITE QUARTERS — COMMAND ROOM${RESET}"; sep_mag
    echo ""
    echo -e "${WHITE}  Mina Ashiro stands before a massive holographic map.${RESET}"
    echo -e "${BOLD}${MAGENTA}  💬 MINA ASHIRO: 'Hibino. That kaiju's percentile exceeds 96%.${RESET}"
    echo -e "${MAGENTA}  You need the ${YELLOW}Crystallized Essence${MAGENTA} to penetrate its core.${RESET}"
    echo -e "${MAGENTA}  Stay safe. I don't want to file another casualty report.'${RESET}"
    echo ""
    echo -e "${CYAN}  💡 HINT: Contaminated Zone → Laboratory → Crystallized Essence${RESET}"
    show_menu "WHAT DO YOU DO?" \
        "☠️ |Travel → Contaminated Zone (find the Essence)|go_loc_contaminated_zone" \
        "⚔️ |Go to the Elite Arsenal|go_zone_elite_arsenal" \
        "🥋|Go to the Dojo|go_zone_dojo" \
        "🔙|Back to Elite Quarters|go_loc_elite_quarters" \
        "🎒|View inventory|inventory"
    read_input; process_selection
}

zone_elite_dojo() {
    clear_screen
    status_bar "Elite Quarters" "Combat Dojo"
    sep_mag
    echo -e "${BOLD}${MAGENTA}  🥋  ELITE QUARTERS — COMBAT DOJO${RESET}"; sep_mag
    cat << 'ASCII_DOJO'

    ⚔️  DEFENSE CORPS TRAINING HALL  ⚔️
    ==========================================
    |   🥋         🥋         🥋            |
    |  [Hoshina]  [Kikoru]  [Recruit]       |
    |    ↓↑         ↓↑        ↓↑            |
    |  [1000%]   [98%]     [???%]           |
    ==========================================
    "Percentile is everything. Train harder."
         — Soshiro Hoshina

ASCII_DOJO
    echo -e "${GRAY}  💬 Hoshina: 'Hibino, you need the elite arsenal. Now.'${RESET}"
    show_menu "WHAT DO YOU DO?" \
        "⚔️ |Go to the Elite Arsenal (Hoshina's weapons)|go_zone_elite_arsenal" \
        "🎖️ |Go to the Command Room|go_zone_command_room" \
        "🔙|Back to Elite Quarters|go_loc_elite_quarters" \
        "🎒|View inventory|inventory"
    read_input; process_selection
}

zone_elite_arsenal() {
    clear_screen
    status_bar "Elite Quarters" "Elite Arsenal"
    sep_mag
    echo -e "${BOLD}${MAGENTA}  ⚔️   ELITE QUARTERS — ELITE ARSENAL${RESET}"; sep_mag
    echo ""
    echo -e "${WHITE}  Weapons you won't find anywhere else.${RESET}"; echo ""
    local opc=()
    if ! has_item "Kaiju-Fiber Katana Type-X"; then
        echo -e "${YELLOW}  ★ ${WHITE}Kaiju-Fiber Katana Type-X${YELLOW} — Forged from kaiju fiber.${RESET}"
        opc+=("⚔️ |Take Kaiju-Fiber Katana Type-X|take_katana")
    else echo -e "${GREEN}  ✓ Kaiju-Fiber Katana Type-X — Already equipped.${RESET}"; fi
    if ! has_item "Reinforced Percentile-92 Suit"; then
        echo -e "${YELLOW}  ★ ${WHITE}Reinforced Percentile-92 Suit${YELLOW} — For high-level kaijus.${RESET}"
        opc+=("🛡️ |Take Reinforced Percentile-92 Suit|take_suit")
    else echo -e "${GREEN}  ✓ Reinforced Percentile-92 Suit — Already equipped.${RESET}"; fi
    opc+=("☠️ |Travel → Contaminated Zone (find the Essence)|go_loc_contaminated_zone")
    opc+=("🥋|Go to the Dojo|go_zone_dojo")
    opc+=("🔙|Back to Elite Quarters|go_loc_elite_quarters")
    opc+=("🎒|View inventory|inventory")
    show_menu "WHAT DO YOU DO?" "${opc[@]}"; read_input; process_selection
}

# ═══════════════════════════════════════════════════════════════
#   LOCATION 5: KAIJU FINAL LAIR
# ═══════════════════════════════════════════════════════════════

loc_kaiju_lair() {
    clear_screen
    status_bar "Kaiju Final Lair" "Select a zone"
    sep_red
    echo -e "${BOLD}${RED}  👹  KAIJU FINAL LAIR${RESET}"; sep_red
    echo -e "${RED}  The air vibrates with dark, intense energy.${RESET}"
    echo -e "${WHITE}  Enormous claw marks cover every surface.${RESET}"
    echo ""
    if ! has_item "Crystallized Kaiju Essence"; then
        echo -e "${BG_RED}${WHITE}  ⚠  WARNING: Without the Crystallized Essence you are at risk.  ${RESET}"
        echo -e "${YELLOW}  Go to Contaminated Zone › Laboratory first.${RESET}"
    else
        echo -e "${GREEN}  ✓ You have the Essence. Go to the Core and attack!${RESET}"
    fi
    show_menu "WHICH ZONE DO YOU GO TO?" \
        "🚷|Lair entrance|go_zone_lair_entrance" \
        "🌑|Deep tunnel — Path to the core|go_zone_deep_tunnel" \
        "💀|★ Kaiju Core ← FINAL BATTLE HERE|go_zone_kaiju_core" \
        "☠️ |Back → Contaminated Zone (get Essence)|go_loc_contaminated_zone" \
        "🏢|Back → Defense Corps Base|go_loc_defense_base" \
        "🎒|View inventory|inventory" \
        "🗺️ |View tactical map|map"
    read_input; process_selection
}

zone_lair_entrance() {
    clear_screen
    status_bar "Kaiju Final Lair" "Entrance"
    sep_red
    echo -e "${BOLD}${RED}  🚷  KAIJU LAIR — ENTRANCE${RESET}"; sep_red
    cat << 'ASCII_LAIR'

    ⚠️  ██████████████████████████████  ⚠️
       ██   EXTREME DANGER ZONE      ██
       ██   UNKNOWN-LEVEL KAIJU      ██
       ██████████████████████████████
              |            |
             \|/          \|/
         ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
         ▓    [LAIR ENTRANCE]   ▓
         ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
              👹 DANGER 👹

ASCII_LAIR
    echo -e "${RED}  Deep growls echo from the depths.${RESET}"
    local opc=()
    if ! has_item "Crystallized Kaiju Essence"; then
        echo -e "${BG_RED}${WHITE}  ⚠  Without the Crystallized Essence you can't damage the boss.  ${RESET}"
        opc+=("☠️ |Back to Contaminated Zone (get the Essence)|go_loc_contaminated_zone")
    fi
    opc+=("🌑|Advance through the Deep Tunnel|go_zone_deep_tunnel")
    opc+=("🔙|Back to the Kaiju Lair|go_loc_kaiju_lair")
    opc+=("🎒|View inventory|inventory")
    show_menu "WHAT DO YOU DO?" "${opc[@]}"; read_input; process_selection
}

zone_deep_tunnel() {
    clear_screen
    status_bar "Kaiju Final Lair" "Deep Tunnel"
    sep_red
    echo -e "${BOLD}${RED}  🌑  KAIJU LAIR — DEEP TUNNEL${RESET}"; sep_red
    echo ""
    echo -e "${WHITE}  The tunnel plunges into darkness. The walls tremble.${RESET}"
    echo -e "${RED}  Red bioluminescence lights the path.${RESET}"; echo ""
    local opc=()
    if ! has_item "Crystallized Kaiju Essence"; then
        echo -e "${BG_RED}${WHITE}  ⚠  NO ESSENCE — The kaiju is completely invulnerable.  ${RESET}"
        echo -e "${YELLOW}  You must go to Contaminated Zone → Laboratory first.${RESET}"
        opc+=("☠️ |Go to Contaminated Zone → Laboratory (ESSENCE HERE)|go_loc_contaminated_zone")
    else
        echo -e "${GREEN}  ✓ You have the Essence. The core can be destroyed!${RESET}"
        echo -e "${BOLD}${RED}  ADVANCE TO THE CORE AND ATTACK!${RESET}"
        opc+=("💀|★ ADVANCE TO THE KAIJU CORE ← FINAL BATTLE|go_zone_kaiju_core")
    fi
    opc+=("🚷|Back to the Lair Entrance|go_zone_lair_entrance")
    opc+=("🔙|Back to the Kaiju Lair|go_loc_kaiju_lair")
    opc+=("🎒|View inventory|inventory")
    show_menu "WHAT DO YOU DO?" "${opc[@]}"; read_input; process_selection
}

zone_kaiju_core() {
    clear_screen
    status_bar "Kaiju Final Lair" "⚠ KAIJU CORE — COMBAT ZONE"
    sep_red
    echo -e "${BOLD}${RED}  💀  KAIJU FINAL CHAMBER${RESET}"; sep_red
    if $ENEMY_DEFEATED; then
        echo -e "${GREEN}  ✓ Kaiju No. 9 was defeated. Threat eliminated.${RESET}"
        victory_screen; return
    fi
    cat << 'ASCII_KAIJU'

               👁️         👁️
           ____|_____________|____
          /  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  \
         |   ~~~  KAIJU NO. 9  ~~~  |
         |  ~~ ☠  [ C O R E ]  ☠ ~~|
          \  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  /
           \______________________/
              ||||          ||||
            !!!PERCENTILE: UNKNOWN!!!
              ⚡⚡ ALERT ⚡⚡

ASCII_KAIJU
    echo -e "${RED}  KAIJU NO. 9 EMERGES FROM THE SHADOWS!${RESET}"; echo ""
    local opc=()
    if ! has_item "Crystallized Kaiju Essence"; then
        echo -e "${BG_RED}${WHITE}  ⚠  NO ESSENCE — Your attacks do nothing.  ${RESET}"
        echo -e "${RED}  The kaiju repels you with a deafening roar.${RESET}"
        opc+=("🏃|Retreat to the Tunnel (flee)|go_zone_deep_tunnel")
        opc+=("☠️ |Go to Contaminated Zone → Laboratory (get Essence)|go_loc_contaminated_zone")
    else
        echo -e "${GREEN}  ✓ You have the Crystallized Essence. You can damage its core!${RESET}"
        opc+=("⚔️ |★ ATTACK Kaiju No. 9 with the Essence! ← WIN THE GAME|attack")
        opc+=("🏃|Retreat (cowardice logged)|go_zone_deep_tunnel")
    fi
    opc+=("🎒|View inventory|inventory")
    show_menu "WHAT DO YOU DO?" "${opc[@]}"; read_input; process_selection
}

# ═══════════════════════════════════════════════════════════════
#   FINAL COMBAT & VICTORY
# ═══════════════════════════════════════════════════════════════

process_attack() {
    if [ "$CURRENT_LOCATION" != "kaiju_lair" ] || [ "$CURRENT_ZONE" != "kaiju_core" ]; then
        echo -e "${YELLOW}  No enemy here. Go to kaiju_core in the Kaiju Lair.${RESET}"; sleep 2; return; fi
    if $ENEMY_DEFEATED; then echo -e "${GREEN}  Already eliminated.${RESET}"; sleep 1; return; fi
    if ! has_item "Crystallized Kaiju Essence"; then
        echo -e "${RED}  Without the Essence your attacks have no effect!${RESET}"; sleep 2; return; fi

    clear_screen; sep_red
    echo -e "${BOLD}${RED}  ⚔  FINAL COMBAT — KAIJU NO. 9  ⚔${RESET}"; sep_red; echo ""
    echo -e "${WHITE}  You raise the Crystallized Kaiju Essence.${RESET}"
    echo -e "${CYAN}  It glows with an intense blue light...${RESET}"; sleep 1; echo ""
    echo -e "${YELLOW}  Kaiju No. 9 roars. Its core reacts to the Essence.${RESET}"; sleep 1; echo ""
    echo -e "${RED}  !!ATTACK!!${RESET}"; sleep 1
    echo -e "${WHITE}  The Essence pierces its shell. The core destabilizes.${RESET}"; sleep 1; echo ""
    has_item "Anti-Kaiju Rifle Type-07"       && { echo -e "${GREEN}  ▸ Anti-Kaiju Rifle — Precision shot at the core...${RESET}"; sleep 1; }
    has_item "Kaiju-Fiber Katana Type-X"      && { echo -e "${GREEN}  ▸ Kaiju-Fiber Katana — Final slash through the core...${RESET}"; sleep 1; }
    echo ""
    echo -e "${BOLD}${YELLOW}  ★★★★★★★★★★★★★★★★★★★★★★★★★★★★${RESET}"
    echo -e "${BOLD}${GREEN}      !!! KAIJU NO. 9 ELIMINATED !!!${RESET}"
    echo -e "${BOLD}${YELLOW}  ★★★★★★★★★★★★★★★★★★★★★★★★★★★★${RESET}"
    sleep 2; ENEMY_DEFEATED=true; victory_screen
}

victory_screen() {
    clear_screen; echo -e "${GREEN}"
    cat << 'ASCII_VICTORY'

  ██╗   ██╗██╗ ██████╗████████╗ ██████╗ ██████╗ ██╗ █████╗
  ██║   ██║██║██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██║██╔══██╗
  ██║   ██║██║██║        ██║   ██║   ██║██████╔╝██║███████║
  ╚██╗ ██╔╝██║██║        ██║   ██║   ██║██╔══██╗██║██╔══██║
   ╚████╔╝ ██║╚██████╗   ██║   ╚██████╔╝██║  ██║██║██║  ██║
    ╚═══╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝

ASCII_VICTORY
    echo -e "${RESET}"; sep
    echo -e "${BOLD}${WHITE}  MISSION COMPLETE, SOLDIER HIBINO!${RESET}"; sep; echo ""
    echo -e "${CYAN}  Kaiju No. 9 has been eliminated.${RESET}"
    echo -e "${MAGENTA}  Mina Ashiro watches you from afar with a faint smile.${RESET}"
    echo -e "${YELLOW}  Your percentile has increased. Tachikawa is safe.${RESET}"; echo ""
    echo -e "${GRAY}  Items collected (${#INVENTORY_LIST[@]}/10):${RESET}"
    for item in "${INVENTORY_LIST[@]}"; do echo -e "  ${GREEN}  ▸ ${WHITE}$item${RESET}"; done
    echo ""; sep
    echo -e "${BOLD}${CYAN}  Thank you for playing KAIJU NO. 8 — OPERATION: DEFENSE CORPS!${RESET}"; sep
    echo ""; GAME_ACTIVE=false
}

# ═══════════════════════════════════════════════════════════════
#   MAIN GAME LOOP
# ═══════════════════════════════════════════════════════════════

game_loop() {
    CURRENT_ZONE="entrance"
    VISITED_ZONES["defense_base:entrance"]=true
    while $GAME_ACTIVE; do
        case "$CURRENT_LOCATION:$CURRENT_ZONE" in
            defense_base:)                  loc_defense_base ;;
            defense_base:entrance)          zone_base_entrance ;;
            defense_base:armory)            zone_base_armory ;;
            defense_base:hangar)            zone_base_hangar ;;
            tachikawa_city:)                loc_tachikawa_city ;;
            tachikawa_city:market)          zone_city_market ;;
            tachikawa_city:hospital)        zone_city_hospital ;;
            tachikawa_city:rooftop)         zone_city_rooftop ;;
            contaminated_zone:)             loc_contaminated_zone ;;
            contaminated_zone:ruins)        zone_contaminated_ruins ;;
            contaminated_zone:laboratory)   zone_contaminated_laboratory ;;
            contaminated_zone:crater)       zone_contaminated_crater ;;
            elite_quarters:)                loc_elite_quarters ;;
            elite_quarters:command_room)    zone_elite_command_room ;;
            elite_quarters:dojo)            zone_elite_dojo ;;
            elite_quarters:elite_arsenal)   zone_elite_arsenal ;;
            kaiju_lair:)                    loc_kaiju_lair ;;
            kaiju_lair:lair_entrance)       zone_lair_entrance ;;
            kaiju_lair:deep_tunnel)         zone_deep_tunnel ;;
            kaiju_lair:kaiju_core)          zone_kaiju_core ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
#   START
# ═══════════════════════════════════════════════════════════════
title_screen
game_loop
echo ""; echo -e "${GRAY}  — SESSION END — DEFENSE CORPS —${RESET}"; echo ""
