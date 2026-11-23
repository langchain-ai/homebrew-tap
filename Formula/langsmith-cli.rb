class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.5.1.tar.gz"
  sha256 "e1e6ecf23920750ec200274d6a4c5bebe1c6924e1bfa5d990cd60bf1f9f7675d"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    manifest_sha256 "ad205f3999a9fd155f1543d3a578ca5cf00e431b6d21b85cafd7268dbd83f062"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "5cbc23c1257642987b0c091e928b18f7e5db1b92e7df930583feee7e22f2b919"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ee6ec883601ab86ea6cae24fcf34f1c16253b8975d17c7968178683fde841cf2"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "5dd9a0a8402c74137c0f8ff3d8f9185b4cb6c6543953809dc70ab2ead1332a69"
    sha256 cellar: :any,                 x86_64_linux:  "e2dcb1c31028c997992b23d29c9b6f01377e2e07f3613905105bb0c81c8ad74b"
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
