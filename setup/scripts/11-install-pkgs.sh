#!/usr/bin/bash
PKG_FILE="$(dirname "$0")/../data/packages"

# Get a list of all currently installed RPM package names to avoid slow individual queries
echo "Checking currently installed system packages..."
INSTALLED_PKGS=$(rpm -qa --qf "%{NAME}\n")

# Array to hold packages that actually need installation
TO_INSTALL=()

# Read the file line by line
while IFS= read -r pkg || [ -n "$pkg" ]; do
  # Trim whitespace and skip empty lines or comments
  pkg=$(echo "$pkg" | xargs)
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

  # Check if the package name exists in our installed list
  if echo "$INSTALLED_PKGS" | grep -Fqx "$pkg"; then
    echo "✓ $pkg is already installed."
  else
    echo "+ $pkg needs to be installed."
    TO_INSTALL+=("$pkg")
  fi
done <"$PKG_FILE"

# If there are packages to install, install them all in a single DNF command
if [ ${#TO_INSTALL[@]} -gt 0 ]; then
  echo "----------------------------------------"
  echo "Installing missing packages: ${TO_INSTALL[*]}"
  echo "----------------------------------------"
  sudo dnf install -y "${TO_INSTALL[@]}"
else
  echo "----------------------------------------"
  echo "All packages are already installed!"
  echo "----------------------------------------"
fi
