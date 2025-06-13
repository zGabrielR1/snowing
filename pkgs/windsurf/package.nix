{ stdenv, lib, curl, jq }:

let
  systemMap = {
    "x86_64-linux" = "linux-x64";
    "x86_64-darwin" = "darwin-x64";
    "aarch64-darwin" = "darwin-arm64";
  };
  targetSystem = systemMap.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  infoUrl = "https://windsurf-stable.codeium.com/api/update/${targetSystem}/stable/latest";
  unpackDir = if stdenv.isDarwin then "Windsurf.app" else "Windsurf";
  binPath = if stdenv.isDarwin then "$out/${unpackDir}/Contents/MacOS/Windsurf" else "$out/${unpackDir}/windsurf";
  iconPath = if stdenv.isDarwin then "$out/${unpackDir}/Contents/Resources/windsurf.icns" else "$out/${unpackDir}/resources/app/resources/linux/code.png";
  desktopFile = if stdenv.isDarwin then null else "$out/${unpackDir}/resources/app/resources/linux/windsurf.desktop";
in
stdenv.mkDerivation {
  pname = "windsurf";
  version = "latest";
  nativeBuildInputs = [ curl jq ];
  buildCommand = ''
    set -e
    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps

    # Fetch info and parse
    curl -s "${infoUrl}" > info.json
    url=$(jq -r .url info.json)
    version=$(jq -r .windsurfVersion info.json)
    sha256=$(jq -r .sha256hash info.json)

    # Download and extract
    curl -L "$url" -o windsurf.tar.gz
    tar -xf windsurf.tar.gz

    # Copy the app bundle or directory
    cp -r ${unpackDir} $out/

    # Symlink the binary
    if [ -f ${binPath} ]; then
      ln -sf ${binPath} $out/bin/windsurf
    fi

    # Copy icon if it exists
    if [ -f ${iconPath} ]; then
      cp ${iconPath} $out/share/icons/hicolor/256x256/apps/windsurf.png
    fi

    # Create desktop file if on Linux
    if [ ! -z "${desktopFile}" ] && [ -f ${desktopFile} ]; then
      cp ${desktopFile} $out/share/applications/windsurf.desktop
      sed -i "s|Exec=.*|Exec=$out/bin/windsurf|" $out/share/applications/windsurf.desktop
    else
      # Fallback desktop file
      cat > $out/share/applications/windsurf.desktop << EOF
      [Desktop Entry]
      Name=Windsurf
      Comment=Agentic IDE powered by AI Flow paradigm
      Exec=$out/bin/windsurf
      Icon=windsurf
      Type=Application
      Categories=Development;IDE;
      EOF
    fi
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