cask "open-swe-desktop" do
  version "0.3.2"
  sha256 "26445098e4757da817847cd9d54b6e9dc34915a93c96c5627f6e63a1b9199374"

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

  zap trash: [
    "~/Library/Application Support/Open SWE",
    "~/Library/Caches/com.langchain.openswe",
    "~/Library/Preferences/com.langchain.openswe.plist",
    "~/Library/Saved Application State/com.langchain.openswe.savedState",
  ]
end
