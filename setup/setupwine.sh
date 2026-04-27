# Wine Installation Script
# This script installs Wine with 32-bit compatibility
#
# KNOWN ISSUE: WineHQ packages have dependency issues with KDE Neon 24.04
# The i386 library libpoppler-glib8t64:i386 is not available.
# WORKAROUND: Use Ubuntu's built-in wine package as fallback.
#
# Usage: ./setupwine.sh [-debug]
#   -debug  Enable debug logging to debuglog.txt

# Parse arguments
DEBUG_MODE=0
for arg in "$@"; do
    case $arg in
        -debug)
            DEBUG_MODE=1
            ;;
    esac
done

# Setup debug logging if requested
if [ $DEBUG_MODE -eq 1 ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    LOG_FILE="$SCRIPT_DIR/debuglog.txt"
    [ -f "$LOG_FILE" ] && rm -f "$LOG_FILE"
    exec > >(tee -a "$LOG_FILE") 2>&1
    echo "=== Wine Setup Debug Log ==="
    echo "Started: $(date)"
    echo ""
fi

echo "Installing Wine..."

# 0. Clean up broken repos from previous runs
echo "Cleaning up broken repositories..."
sudo rm -f /etc/apt/sources.list.d/winehq-debian.list 2>/dev/null || true
sudo rm -f /etc/apt/sources.list.d/winehq-noble.sources 2>/dev/null || true

# 1. Enable 32-bit architecture
echo "Enabling 32-bit architecture..."
sudo dpkg --add-architecture i386

# 2. Get codename
CODENAME=$(. /etc/os-release; echo $UBUNTU_CODENAME)
[[ -z "$CODENAME" ]] && CODENAME=$(lsb_release -cs)
echo "Detected codename: $CODENAME"

# 3. Setup WineHQ keyring
echo "Setting up WineHQ keyring..."
sudo mkdir -pm 755 /etc/apt/keyrings
sudo wget -qO /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key 2>&1

# 4. Add fresh WineHQ repo
echo "Adding WineHQ repository..."
echo "deb [arch=amd64] https://dl.winehq.org/wine-builds/ubuntu $CODENAME main" | sudo tee /etc/apt/sources.list.d/winehq-ubuntu.list > /dev/null
echo "deb [arch=i386] https://dl.winehq.org/wine-builds/ubuntu $CODENAME main" | sudo tee -a /etc/apt/sources.list.d/winehq-ubuntu.list > /dev/null

# 5. Update
echo "Running apt update..."
sudo apt update 2>&1 | grep -E "^(Err|W:|E:)" | head -5

if [ $DEBUG_MODE -eq 1 ]; then
    echo "=== Available wine versions ==="
    apt-cache madison winehq-devel 2>&1 | head -2
fi

# 6. Try WineHQ installation
echo "Attempting WineHQ installation..."
WINE_RESULT=$(sudo apt install --install-recommends -y winehq-devel 2>&1)
WINE_EXIT=$?

echo "$WINE_RESULT" | tail -10

# Check if actually installed
if dpkg -l | grep -q "winehq-devel"; then
    echo "WineHQ installed successfully!"
else
    echo "WineHQ installation failed, installing Ubuntu wine package instead..."
    
    # Install Ubuntu wine
    echo "Installing Ubuntu wine..."
    UBUNTU_RESULT=$(sudo apt install --install-recommends -y wine wine32 wine64 2>&1)
    UBUNTU_EXIT=$?
    
    echo "$UBUNTU_RESULT" | tail -10
    
    if dpkg -l | grep -q "wine "; then
        echo "Ubuntu wine installed successfully!"
    else
        echo "Ubuntu wine also failed - trying basic wine only..."
        sudo apt install -y wine 2>&1 | tail -5
    fi
fi

echo ""
echo "=== Checking installed wine packages ==="
dpkg -l | grep -i "^ii.*wine" | head -10

echo ""
which wine 2>/dev/null && wine --version 2>/dev/null || echo "wine command not found in PATH"

echo ""
echo "=== Setup Complete ==="
if [ $DEBUG_MODE -eq 1 ]; then
    echo "Debug log saved to: $LOG_FILE"
fi