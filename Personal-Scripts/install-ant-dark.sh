#!/usr/bin/env bash
# ============================================================
#  install-ant-dark.sh
#  Installeert de Ant-Dark Plasma theme op Arch / Manjaro
#  Inclusief: Kvantum engine, Plasma style, kleurschema
# ============================================================

set -euo pipefail

# ---- Kleuren voor output ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

THEME_NAME="Ant-Dark"
STORE_URL="https://store.kde.org/p/1464332"
GITHUB_URL="https://github.com/EliverLara/Ant"

PLASMA_THEME_DIR="$HOME/.local/share/plasma/desktoptheme"
LOOKNFEEL_DIR="$HOME/.local/share/plasma/look-and-feel"
COLOR_DIR="$HOME/.local/share/color-schemes"
KVANTUM_DIR="$HOME/.config/Kvantum"
TMP_DIR=$(mktemp -d)

# ---- Functies ----
info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

check_dep() {
    command -v "$1" &>/dev/null || error "Vereist programma niet gevonden: $1. Installeer het eerst."
}

# ---- Banner ----
echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════╗"
echo "║      Ant-Dark KDE Theme Installer        ║"
echo "║         Arch / Manjaro editie            ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ---- Vereisten controleren ----
info "Controleren van vereisten..."
check_dep git
check_dep curl

# ---- Kvantum installeren ----
info "Kvantum engine installeren (indien nodig)..."
if ! pacman -Qi kvantum &>/dev/null 2>&1; then
    if command -v yay &>/dev/null; then
        yay -S --noconfirm kvantum
    elif command -v paru &>/dev/null; then
        paru -S --noconfirm kvantum
    else
        sudo pacman -S --noconfirm kvantum
    fi
    success "Kvantum geïnstalleerd."
else
    success "Kvantum was al geïnstalleerd."
fi

# ---- Mappen aanmaken ----
info "Mappen aanmaken..."
mkdir -p "$PLASMA_THEME_DIR" "$LOOKNFEEL_DIR" "$COLOR_DIR" "$KVANTUM_DIR"

# ---- Ant-KDE klonen van GitHub ----
info "Ant-Dark theme downloaden van GitHub..."
cd "$TMP_DIR"
git clone --depth=1 "$GITHUB_URL" Ant || error "Kon de repository niet klonen. Controleer je internetverbinding."
success "Download voltooid."

REPO_KDE="$TMP_DIR/Ant/kde/Dark"

# ---- Plasma desktoptheme installeren ----
info "Plasma desktoptheme installeren..."
if [ -d "$REPO_KDE/plasma/desktoptheme/Ant-Dark" ]; then
    cp -r "$REPO_KDE/plasma/desktoptheme/Ant-Dark" "$PLASMA_THEME_DIR/"
    success "Plasma desktoptheme geïnstalleerd → $PLASMA_THEME_DIR/Ant-Dark"
else
    warn "Plasma desktoptheme map niet gevonden. Controleer de repo structuur."
fi

# ---- Kleurschema installeren ----
info "Kleurschema installeren..."
COLORFILE=$(find "$TMP_DIR/Ant" -name "*.colors" | head -n1)
if [ -n "$COLORFILE" ]; then
    cp "$COLORFILE" "$COLOR_DIR/"
    success "Kleurschema geïnstalleerd → $COLOR_DIR/$(basename "$COLORFILE")"
else
    warn "Geen .colors bestand gevonden in de repository."
fi

# ---- Kvantum theme installeren ----
info "Kvantum theme installeren..."
KVANTUM_SRC=$(find "$TMP_DIR/Ant" -type d -name "Kvantum" | head -n1)
if [ -n "$KVANTUM_SRC" ]; then
    cp -r "$KVANTUM_SRC"/. "$KVANTUM_DIR/"
    success "Kvantum theme geïnstalleerd → $KVANTUM_DIR/"
else
    warn "Geen Kvantum map gevonden. Sla deze stap over."
fi

# ---- Opruimen ----
info "Tijdelijke bestanden opruimen..."
rm -rf "$TMP_DIR"
success "Opgeruimd."

# ---- Plasma herladen ----
info "Plasma desktop herladen..."
if command -v plasmashell &>/dev/null; then
    kquitapp5 plasmashell 2>/dev/null || true
    sleep 1
    kstart5 plasmashell 2>/dev/null &
    success "Plasma herstart."
else
    warn "Kon Plasma niet automatisch herstarten. Doe dit handmatig of log opnieuw in."
fi

# ---- Afsluitinstructies ----
echo ""
echo -e "${BOLD}${GREEN}✔ Installatie voltooid!${NC}"
echo ""
echo -e "${BOLD}Volgende stappen om het theme te activeren:${NC}"
echo -e "  ${CYAN}1.${NC} Systeeminstellingen → Uiterlijk → ${BOLD}Plasma Stijl${NC} → selecteer ${BOLD}Ant-Dark${NC} → Toepassen"
echo -e "  ${CYAN}2.${NC} Systeeminstellingen → Uiterlijk → ${BOLD}Kleuren${NC} → selecteer ${BOLD}Ant-Dark${NC} → Toepassen"
echo -e "  ${CYAN}3.${NC} Systeeminstellingen → Uiterlijk → ${BOLD}Applicatiestijl${NC} → stel in op ${BOLD}kvantum${NC}"
echo -e "  ${CYAN}4.${NC} Open ${BOLD}Kvantum Manager${NC} → selecteer en pas ${BOLD}Ant-Dark${NC} toe"
echo ""
echo -e "  Meer info: ${YELLOW}$STORE_URL${NC}"
echo ""
