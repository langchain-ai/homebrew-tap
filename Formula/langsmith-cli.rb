class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.2.54.tar.gz"
  sha256 "85f983ba21a38be423b01d58dcfdac84b90519629dc9aed195d15ec663c4a186"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c81f56cd1526d25c2c65ddd7b996e74b3cddf8d54f1db8aeb6a50623d6c88a83"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0ed7ee5ce7105aa1be1c50f3496eec49e6b292d7d31acbce1b10364635ffba81"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "cfdb2b2e72c76bc178bdb4c57adf97701dbc5c5c9b03cadaf7bb95996c4e6e4f"
    sha256 cellar: :any,                 x86_64_linux:  "d628bf66c05272deb2750fa67a91f5d5c73c63ec7f10fff770d5946efac17331"
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
