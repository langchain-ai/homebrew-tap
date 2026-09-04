cask "open-swe" do
  version "0.2.6"
  sha256 "1ea806c2bbde67b98a86b615d2fea660fd70dbf51dfff9fc43ac8cba38c40d7a"

  url "https://github.com/langchain-ai/open-swe/releases/download/desktop-v#{version}/Open-SWE-#{version}-arm64.dmg"
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
