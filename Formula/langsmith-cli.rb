class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "9c27b7a53277c9495b8896c9717779f1e369ad01c7a5098f3189b6616585c3d5"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "13ce785b2fd799f14132a668d72ef05c5b62ddaa3179d5c8b57ca32df99a82ef"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c764a817c5c41eec4714e3a93767ceb3c5a7992efa609b80b6024252b4e1747f"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "4fb5961e61f24bb12167fe4ce2bec8da1a58fe48f15eee44287aba0ef865f1e8"
    sha256 cellar: :any,                 x86_64_linux:  "3a51c542e32441b368f3d77f3b7411ce75de50ca915beac83492c8a6ac443d41"
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
