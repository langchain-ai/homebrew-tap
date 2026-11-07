cask "open-swe-desktop" do
  version "0.3.14"
  sha256 "98efb4fb4b8a4afab301b1dcea56d9dd8453e1c2a738a671a149f4ce976cfcd4"

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
