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

# ── 4. SSH key controleren/aanmaken ──
echo "🔑 SSH key controleren..."

SSH_KEY="$HOME/.ssh/id_ed25519"

if [ -f "$SSH_KEY" ]; then
  echo "✅ SSH key gevonden: $SSH_KEY"
else
  echo "   Geen SSH key gevonden, aanmaken..."
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "sjoerd@ictkanon.com" -f "$SSH_KEY" -N ""
  echo "✅ SSH key aangemaakt."
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⚠️  Voeg de volgende public key toe aan GitHub:"
  echo "   https://github.com/settings/ssh/new"
  echo ""
  cat "${SSH_KEY}.pub"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  read -rp "   Druk op Enter zodra je de key hebt toegevoegd aan GitHub..."
  echo ""
fi

# SSH agent starten en key laden
eval "$(ssh-agent -s)" > /dev/null
ssh-add "$SSH_KEY" 2>/dev/null
echo "   SSH agent gestart en key geladen."

# Verbinding testen
echo "   GitHub verbinding testen..."
SSH_TEST=$(ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true)
if echo "$SSH_TEST" | grep -q "successfully authenticated"; then
  echo "✅ GitHub SSH verbinding OK"
else
  echo "⚠️  GitHub SSH test resultaat: $SSH_TEST"
  echo "   Controleer of de key correct is toegevoegd en probeer opnieuw."
  read -rp "   Doorgaan ondanks waarschuwing? (j/n): " CONTINUE
  if [[ "$CONTINUE" != "j" && "$CONTINUE" != "J" ]]; then
    echo "❌ Setup afgebroken."
    exit 1
  fi
fi
echo ""

# ── 5. GitHub repos clonen ──
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
clone_repo "IntuneBackup"               "$GIT_DIR/Intune-Backups"
clone_repo "CA-Policies"                "$GIT_DIR/CA-policies"
clone_repo "Klantenportaal_new"         "$GIT_DIR/Klantenportaal"
clone_repo "Platform"                   "$GIT_DIR/Platform"


# Devel branches (aparte map)
clone_repo "Windows-Powershell"         "$DEVEL_DIR/Windows-Powershell"  "devel"
clone_repo "M365-Scripts"               "$DEVEL_DIR/M365-Scripts"        "devel"
clone_repo "PR-Website"                 "$DEVEL_DIR/PR-Website"          "development"
clone_repo "Werkbon"                    "$DEVEL_DIR/Werkbon"             "devel"
clone_repo "Klantenportaal_new"         "$DEVEL_DIR/Klantenportaal"      "devel"
clone_repo "Platform"                   "$GIT_DIR/Platform"              "devel"
echo "✅ Repos gecloned."
echo ""

# ── 6. Overzicht ──
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
echo "   ├── Werkbon                 (main)"
echo "   ├── FirstITHub-Intune-Backups"
echo "   ├── Klantenportaal          (main)"
echo "   └── devel/"
echo "       ├── Windows-Powershell  (devel branch)"
echo "       ├── M365-Scripts        (devel branch)"
echo "       ├── PR-Website          (development branch)"
echo "       ├── Werkbon             (devel branch)"
echo "       └── Klantenportaal      (devel branch)"
echo ""
echo "🔑 SSH:"
echo "   Key: ~/.ssh/id_ed25519"
echo "   Public key: ~/.ssh/id_ed25519.pub"
echo ""
echo "🔧 VS Code:"
echo "   - GitDoc + GitLens + Git Graph geïnstalleerd"
echo "   - Autosave ingeschakeld (1 seconde delay)"
echo "   - GitDoc staat standaard UIT"
echo ""
echo "⚠️  GitDoc per repo aanzetten via de statusbalk in VS Code"
echo "============================================"
