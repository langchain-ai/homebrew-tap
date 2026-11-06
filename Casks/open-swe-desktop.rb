cask "open-swe-desktop" do
  version "0.3.13"
  sha256 "c9ab0a63643c8a40937441aededd651e98fd7aaf5e6ff79885e4399e259cc44d"

  # Desktop 0.3.13 renames the app to Robin: its DMG holds Robin.app, which
  # bundles a `robin` CLI next to the legacy `oswe`. Earlier releases ship
  # Open SWE.app with `oswe` only. Drop the Open SWE branch once the cask is
  # past 0.3.13.
  robin = Version.new(version) >= Version.new("0.3.13")
  app_name = robin ? "Robin.app" : "Open SWE.app"

  url "https://github.com/langchain-ai/open-swe/releases/download/desktop-v#{version}/#{robin ? "Robin" : "Open-SWE"}-#{version}-arm64-mac.dmg"
  name "Robin"
  name "Open SWE"
  desc "Cloud coding agent for software development"
  homepage "https://github.com/langchain-ai/open-swe"

  livecheck do
    url :url
    regex(/^desktop-v?(\d+(?:\.\d+)+)$/i)
    strategy :github_latest
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :ventura

  app app_name
  binary "#{appdir}/#{app_name}/Contents/Resources/bin/oswe"

  binary "#{appdir}/#{app_name}/Contents/Resources/bin/robin" if robin

  zap trash: [
    "~/Library/Application Support/Open SWE",
    "~/Library/Caches/com.langchain.openswe",
    "~/Library/Preferences/com.langchain.openswe.plist",
    "~/Library/Saved Application State/com.langchain.openswe.savedState",
  ]
end
