class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.2.43.tar.gz"
  sha256 "6f530ccab7a2bc96f20c192bade4a9dcaf15c7f2e0d0eb58d0dbddd0d66dfc54"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "09c892aad91ec293fbbb4c0aaa3ae1980fe7b007c9171a6d4bdd722c3287c0b5"
    sha256 cellar: :any,                 x86_64_linux: "b2bda89af5391d8a4d05a5195e39b498fbc0a8fe0b506b9b832c12f6478c7dd4"
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
