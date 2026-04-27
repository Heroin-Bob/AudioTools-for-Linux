#!/bin/bash
# Requirements Test Script
# Checks if all required packages are installed

echo "======================================"
echo "   Audio Tools Requirements Check   "
echo "======================================"
echo ""

PASS=0
FAIL=0

check_package() {
    local cmd="$1"
    local name="$2"
    local version_flag="$3"
    
    if which "$cmd" >/dev/null 2>&1; then
        if [ -n "$version_flag" ]; then
            local version=$($cmd $version_flag 2>/dev/null | head -1)
            echo "[✓] $name installed: $version"
        else
            echo "[✓] $name installed"
        fi
        ((PASS++))
    else
        echo "[✗] $name NOT installed"
        ((FAIL++))
    fi
}

echo "--- Core Dependencies (Required) ---"
check_package "wget" "wget" "--version"
check_package "fc-cache" "fontconfig" "-v 2>&1 | head -1"

echo ""
echo "--- Core Dependencies (Optional) ---"
if flatpak list 2>/dev/null | grep -qi dotnet || dpkg -l | grep -qi "^ii.*dotnet"; then
    local dotver=$(dotnet --version 2>/dev/null)
    echo "[✓] dotnet installed: $dotver"
    ((PASS++))
else
    echo "[*] dotnet NOT installed (optional)"
fi

echo ""
echo "--- Audio Stack ---"
check_package "pipewire" "Pipewire" "--version"
check_package "pw-dump" "PipeWire (tools)"

echo ""
echo "--- Windows Compatibility ---"
check_package "wine" "Wine" "--version"
if which wine64 >/dev/null 2>&1 || dpkg -l | grep -q "^ii.*wine64"; then
    echo "[✓] Wine (64-bit) installed"
    ((PASS++))
else
    echo "[✗] Wine (64-bit) NOT installed"
    ((FAIL++))
fi

echo ""
echo "--- yabridge (VST Bridge) ---"
check_package "yabridgectl" "yabridgectl" "--version"
check_package "yabridge-host.exe" "yabridge host"

echo ""
echo "======================================"
echo "           Summary                   "
echo "======================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "✓ All requirements are installed!"
    exit 0
else
    echo "✗ Some requirements are missing."
    echo "Run ./setupreqs.sh to install missing packages."
    exit 1
fi