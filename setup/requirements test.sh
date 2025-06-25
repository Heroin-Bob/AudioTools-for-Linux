if which dotnet >/dev/null 2>&1; then
 echo "dotnet installed: $(dotnet --version)"
else
 echo "dotnet not installed"
fi
echo 
if which curl >/dev/null 2>&1; then
 echo "curl installed: $(curl --version)"
else
 echo "curl not installed"
fi
echo 
if which pipewire >/dev/null 2>&1; then
 echo "pipewire installed: $(pipewire --version)"
else
 echo "pipewire not installed"
fi
echo 
if which wine >/dev/null 2>&1; then
 echo "Wine installed: $(wine --version) Note: Version must be <9.21"
else
 echo "wine not installed"
fi
echo
if which yabridgectl >/dev/null 2>&1; then
 echo "yabridge installed: $(yabridgectl --version)"
else
 echo "yabridge not installed"
fi
