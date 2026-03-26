#!/bin/bash
# ============================================
# ICTKanon Dev Setup Script
# VS Code + GitDoc + GitHub repos
# CachyOS (Arch-based)
# Sjoerd Kanon - sjoerd@ictkanon.com
# ============================================

set -e

echo "============================================"
echo " ICTKanon Dev Setup - CachyOS"
echo "============================================"
echo ""

# ── 1. VS Code installeren indien nodig ──
if ! command -v code &>/dev/null; then
  echo "📦 VS Code niet gevonden, installeren via yay..."
  yay -S --noconfirm visual-studio-code-bin
else
  echo "✅ VS Code gevonden: $(code --version | head -1)"
fi
echo ""

# ── 2. Extensies installeren via Microsoft Marketplace ──
echo "📦 Extensies installeren..."

code --install-extension vsls-contrib.gitdoc    # GitDoc
code --install-extension eamodio.gitlens        # GitLens
code --install-extension mhutchie.git-graph     # Git Graph

echo "✅ Extensies geïnstalleerd."
echo ""

# ── 3. VS Code settings.json aanmaken ──
echo "⚙️  VS Code settings configureren..."

SETTINGS_DIR="$HOME/.config/Code/User"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

mkdir -p "$SETTINGS_DIR"

if [ -f "$SETTINGS_FILE" ]; then
  cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak"
  echo "   Backup gemaakt → settings.json.bak"
fi

cat > "$SETTINGS_FILE" << 'EOF'
{
  // ── Autosave ──
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,

  // ── GitDoc ──
  "gitdoc.enabled": false,
  "gitdoc.autoPush": "onCommit",
  "gitdoc.commitMessageFormat": "Auto-commit: {{now}}",
  "gitdoc.filePattern": "**/*",
  "gitdoc.autoCommitDelay": 30000,
  "gitdoc.excludePatterns": [
    "**/.git/**",
    "**/node_modules/**",
    "**/*.log"
  ],

  // ── Git algemeen ──
  "git.enableSmartCommit": true,
  "git.confirmSync": false,
  "git.autofetch": true,

  // ── Editor ──
  "editor.formatOnSave": true,
  "editor.tabSize": 2
}
EOF

echo "✅ settings.json aangemaakt."
echo ""

# ── 4. GitHub repos clonen ──
echo "📁 GitHub repos clonen..."

GIT_DIR="$HOME/git"
DEVEL_DIR="$HOME/git/devel"

mkdir -p "$GIT_DIR"
mkdir -p "$DEVEL_DIR"

clone_repo() {
  local REPO=$1
  local DIR=$2
  local BRANCH=$3

  if [ -d "$DIR/.git" ]; then
    echo "   ⏭️  $DIR bestaat al, overgeslagen."
  else
    echo "   Clonen: $REPO → $DIR"
    git clone "git@github.com:sjkanon/${REPO}.git" "$DIR"
    if [ -n "$BRANCH" ]; then
      git -C "$DIR" checkout "$BRANCH"
      echo "   Branch: $BRANCH"
    fi
  fi
}

# Main branches
clone_repo "logboek"                    "$GIT_DIR/logboek"
clone_repo "ICTKanon"                   "$GIT_DIR/ICTKanon"
clone_repo "Windows-Powershell"         "$GIT_DIR/Windows-Powershell"
clone_repo "M365-Scripts"               "$GIT_DIR/M365-Scripts"
clone_repo "PR-Website"                 "$GIT_DIR/PR-Website"
clone_repo "Werkbon"                    "$GIT_DIR/Werkbon"
clone_repo "FirstITHub-Intune-Backups"  "$GIT_DIR/FirstITHub-Intune-Backups"

# Devel branches (aparte map)
clone_repo "Windows-Powershell"         "$DEVEL_DIR/Windows-Powershell"   "devel"
clone_repo "M365-Scripts"               "$DEVEL_DIR/M365-Scripts"         "devel"
clone_repo "PR-Website"                 "$DEVEL_DIR/PR-Website"           "development"

echo "✅ Repos gecloned."
echo ""

# ── 5. Overzicht ──
echo "============================================"
echo "✅ Setup voltooid!"
echo ""
echo "📁 Repo structuur:"
echo "   ~/git/"
echo "   ├── logboek"
echo "   ├── ICTKanon"
echo "   ├── Windows-Powershell      (main)"
echo "   ├── M365-Scripts            (main)"
echo "   ├── PR-Website              (main)"
echo "   ├── FirstITHub-Intune-Backups"
echo "   └── devel/"
echo "       ├── Windows-Powershell  (devel branch)"
echo "       ├── M365-Scripts        (devel branch)"
echo "       └── PR-Website          (development branch)"
echo ""
echo "🔧 VS Code:"
echo "   - GitDoc + GitLens + Git Graph geïnstalleerd"
echo "   - Autosave ingeschakeld (1 seconde delay)"
echo "   - GitDoc staat standaard UIT"
echo ""
echo "⚠️  GitDoc per repo aanzetten via de statusbalk in VS Code"
echo "============================================"
