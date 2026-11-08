cask "open-swe-desktop" do
  version "0.3.15"
  sha256 "cbad544769426fcf798d59f9571bacf5a1bef5ccde70582eb2742bdbfd873b2f"

  url "https://github.com/langchain-ai/open-swe/releases/download/desktop-v#{version}/Robin-#{version}-arm64-mac.dmg"
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

  app "Robin.app"
  binary "#{appdir}/Robin.app/Contents/Resources/bin/oswe"
  binary "#{appdir}/Robin.app/Contents/Resources/bin/robin"

  zap trash: [
    "~/Library/Application Support/Open SWE",
    "~/Library/Caches/com.langchain.openswe",
    "~/Library/Preferences/com.langchain.openswe.plist",
    "~/Library/Saved Application State/com.langchain.openswe.savedState",
  ]
end
