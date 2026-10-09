class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "7e62d223f6ae30b2130a01f90530468392d222d2936552cc91e1334fd33d6f62"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "77391257cf46f9737cd7c8779733dc678402c279995cc1b8e28a14a632c9d706"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "34a5a591425e0bb3a7d1fb5695bc7009b88df1410a1b2f31fd4e46aa9b74c603"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "70a030286d10943e7a3b07500362afe592b35e33ec9f6923617898461c9b6000"
    sha256 cellar: :any,                 x86_64_linux:  "8579f162f7d2a80091dfd7920c6cc6cbf1ad40f96f9edfc34654fe8779a13391"
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
