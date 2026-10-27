class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.3.8.tar.gz"
  sha256 "97247068d71df5135fb2aee9843140fbe94536170385197a73d8479d353a79d4"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "404fd880b682696b0e650fbc501d1f6681d993b95308dac8cda57519d04c1094"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "6b23fe536f5b78e55e686ec9dc17264a92dfda6b19725e7bc9291e18c819ab72"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "a11670390bafcbe29834fa039cffebb41827c9ca0d97d60c8cb87a390ef32732"
    sha256 cellar: :any,                 x86_64_linux:  "40cf8e4350c8583a3d3440f3e12da6b03ee2a633fe824b05823f9e0094f5adb0"
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
