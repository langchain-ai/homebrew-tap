class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "7e62d223f6ae30b2130a01f90530468392d222d2936552cc91e1334fd33d6f62"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "cb8a9b4539171ebb3731dd58b70cb2207545c19d040b2fd292de3e56200a4888"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "73f51a7b0bca78158df20d0363df9000defaae7e6690c1b6879f3b2531f97f99"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "90a68dde48f127374fdf24e1168f2948c805a8cdb7df5757e3004f714ab7297d"
    sha256 cellar: :any,                 x86_64_linux:  "71e9a78e047f1e24c3fb18c49b78aab43eb6b75eb1aabd9e5b64234104081236"
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
