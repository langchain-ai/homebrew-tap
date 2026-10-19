class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.3.4.tar.gz"
  sha256 "5591d982ea220504a1df1e28606fe8815433b394226cce6f62e1bf07d0b54661"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "ad064c792e681840708074d68185d6bfe238cd1c0405ba54ef5b753ac6763899"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "8b7fc7f04225691bca8f554cfd07712d3fd7c350f90e9630a4c8260796654ca0"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "aa20196ab3233a35b6baa70f067a09e22fa2e354c5f1b044f710c4a38f21f960"
    sha256 cellar: :any,                 x86_64_linux:  "73dc19bd361c89a233c892ab68a718553b42ae42050f32319681540cd9886997"
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
