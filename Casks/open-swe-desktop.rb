cask "open-swe-desktop" do
  version "0.2.7"
  sha256 "04d2136233c5862941f01b52c91f6ee89f698c1386b35578be6794f1ae40cfae"

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
