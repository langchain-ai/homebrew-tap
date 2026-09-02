class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.2.54.tar.gz"
  sha256 "85f983ba21a38be423b01d58dcfdac84b90519629dc9aed195d15ec663c4a186"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "7a1c4eb49657e2409e38f263a545dd62f299d8c7a438ae66b7701fcda7ebc972"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9bf313dc5154aa3ad6931f383716ef45eb19825bda88e43f16023bc1d8789f6d"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "b1fe84df1c6546fac77188e67cbf41c0d19fae03a70e32410699cdf624202acd"
    sha256 cellar: :any,                 x86_64_linux:  "cd42e4f5f4218acca6d2faf18be28638e44bf967a2e6e5803eeda5b1dee284d3"
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
