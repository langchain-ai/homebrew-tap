class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.3.8.tar.gz"
  sha256 "97247068d71df5135fb2aee9843140fbe94536170385197a73d8479d353a79d4"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "a88dd4640dc04a1897497b79542f02685eba23f3e61c6c0d143a94f79822c434"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "3642a5742d48c1f253a2ba21e771c5e85f213833d2f64da84bc23ca54ef35085"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "8ca92b36f5e9858a913fae9fc813fb2119899bec11dcc00e7f638e9a1b730a56"
    sha256 cellar: :any,                 x86_64_linux:  "e7d31592658b4a9586304082f526cecd092787f280d8ca6a3e1934fb92fc5361"
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
