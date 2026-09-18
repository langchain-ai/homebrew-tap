class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.2.58.tar.gz"
  sha256 "f84b672efdc9fa354ab8c39fff5e1e5659e23f662dc239fed5cba25316dafb91"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "81a6bd740b9bda6bbbb50e4ec6a303fea3137023f3cb0d935711beb5f1c9a239"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "db403be0dc48555301b2f86634438153bbc2221732a40131078b7efc14148008"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "a7ecee24425b87b152eb4fcb5ef8caeaab0ede15b3dfb3db8f2c51b6d1222aaa"
    sha256 cellar: :any,                 x86_64_linux:  "7285e93a14da027d448ebc40d6e900f0ca101bca7e6f3287031f5e7c8dcb8737"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X main.version=#{version}
    ]
    system "go", "build", *std_go_args(output: bin/"langsmith", ldflags:), "./cmd/langsmith"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/langsmith --version")

    output = shell_output("#{bin}/langsmith hub init --type agent --dir myagent --name demo-agent")
    assert_match "scaffolded", output
    assert_predicate testpath/"myagent", :directory?
  end
end
