cask "open-swe-desktop" do
  version "0.2.8"
  sha256 "725bb372353ceef8f77fd3880b631f4a3261d8246bc479401ecc1dcc7fd5804d"

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
  depends_on macos: :monterey

  app "Open SWE.app"

  zap trash: [
    "~/Library/Application Support/Open SWE",
    "~/Library/Caches/com.langchain.openswe",
    "~/Library/Preferences/com.langchain.openswe.plist",
    "~/Library/Saved Application State/com.langchain.openswe.savedState",
  ]
end
