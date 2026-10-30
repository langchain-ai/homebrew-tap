class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.3.13.tar.gz"
  sha256 "bf5ac7174f0f91aa7638bb5225c1460e7c87f2c8fb39aa7f9129ba859e15de4d"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "2b72f84df2143d2ee0c6ab80014d2eb26ad415f8b7ef7a14acc72a76ff4a6f94"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "2eda6aeae4c71ac39c13706561f6f9d368f495604079bea733a1f42b943ea513"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "290803c42ca6a6c17a223f7452734b88b28cb285a1a543b3d7ddf004604451d5"
    sha256 cellar: :any,                 x86_64_linux:  "5982b5b9d3ea322c066ffc56fbddfc2db773f7fa265e48f6c39f467e438bd8b1"
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
