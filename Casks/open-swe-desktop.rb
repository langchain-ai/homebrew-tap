cask "open-swe-desktop" do
  version "0.3.10"
  sha256 "c273c840ae46bf2ae25a38fe6a9d570da7659ee393c5fb4c6afada338758ffbc"

  url "https://github.com/langchain-ai/open-swe/releases/download/desktop-v#{version}/Open-SWE-#{version}-arm64-mac.dmg"
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

  app "Open SWE.app"
  binary "#{appdir}/Open SWE.app/Contents/Resources/bin/oswe"

  zap trash: [
    "~/Library/Application Support/Open SWE",
    "~/Library/Caches/com.langchain.openswe",
    "~/Library/Preferences/com.langchain.openswe.plist",
    "~/Library/Saved Application State/com.langchain.openswe.savedState",
  ]
end
