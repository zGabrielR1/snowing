{ stdenv, lib, fetchurl }:

let
  # Windsurf version and build info
  version = "1.10.3";
  buildHash = "c1afeb8ae2b17dbdda415f9aa5dec23422c1fe47";
  
  # Map Nix system to Windsurf system
  systemMap = {
    "x86_64-linux" = "linux-x64";
    "x86_64-darwin" = "darwin-x64";
    "aarch64-darwin" = "darwin-arm64";
  };
  targetSystem = systemMap.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  
  # Construct the download URL
  url = "https://windsurf-stable.codeiumdata.com/${targetSystem}/stable/${buildHash}/Windsurf-${targetSystem}-${version}.tar.gz";
  
  # For now, using a placeholder hash - you'll need to update this
  # You can get the actual hash by running: nix-prefetch-url "https://windsurf-stable.codeiumdata.com/linux-x64/stable/c1afeb8ae2b17dbdda415f9aa5dec23422c1fe47/Windsurf-linux-x64-1.10.3.tar.gz"
  sha256 = "1ywd53mp2i2vic52kswnkbxy3fyyi485sqvj69n9y60l8xi333v3";
  
  src = fetchurl {
    inherit url sha256;
  };
  
  unpackDir = if stdenv.isDarwin then "Windsurf.app" else "Windsurf";
  binPath = if stdenv.isDarwin then "Contents/MacOS/Windsurf" else "windsurf";
  
in stdenv.mkDerivation {
  pname = "windsurf";
  inherit version src;
  
  nativeBuildInputs = [ ];
  
  buildCommand = ''
    set -e
    echo "Building Windsurf ${version} for ${targetSystem}..."
    
    # Create output directories
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/256x256/apps
    
    # Extract the archive
    echo "Extracting Windsurf..."
    tar -xf $src
    
    # Copy the extracted directory
    cp -r ${unpackDir} $out/
    
    # Create symlink to the binary
    if [ -f "$out/${unpackDir}/${binPath}" ]; then
      ln -sf $out/${unpackDir}/${binPath} $out/bin/windsurf
      echo "Binary symlinked successfully"
    else
      echo "Could not find Windsurf binary at $out/${unpackDir}/${binPath}"
      ls -la $out/${unpackDir}/
      exit 1
    fi
    
    # Copy icon if it exists
    if [ -f "$out/${unpackDir}/resources/app/resources/linux/code.png" ]; then
      cp "$out/${unpackDir}/resources/app/resources/linux/code.png" $out/share/icons/hicolor/256x256/apps/windsurf.png
    elif [ -f "$out/${unpackDir}/Contents/Resources/windsurf.icns" ]; then
      cp "$out/${unpackDir}/Contents/Resources/windsurf.icns" $out/share/icons/hicolor/256x256/apps/windsurf.icns
    fi
    
    # Create desktop file
    cat > $out/share/applications/windsurf.desktop << EOF
    [Desktop Entry]
    Name=Windsurf
    Comment=Agentic IDE powered by AI Flow paradigm
    Exec=$out/bin/windsurf
    Icon=windsurf
    Type=Application
    Categories=Development;IDE;
    EOF
    
    echo "Windsurf ${version} built successfully!"
  '';
  
  meta = {
    description = "Agentic IDE powered by AI Flow paradigm";
    longDescription = ''
      The first agentic IDE, and then some.
      The Windsurf Editor is where the work of developers and AI truly flow together, allowing for a coding experience that feels like literal magic.
    '';
    homepage = "https://codeium.com/windsurf";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
} 