class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "686b0f8c7738216a8d2786e45e53df313e5d6aea36d8cc92aa0d8161fd953d6f"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f309f876c22c7a798a9285035d18aa0bc9fba1d03a6fd270efff79a66936956c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d369602f12ba58a4f64546540376c2dd5219f602bed3250948ebfbe4d5e771aa"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "afb136433281f3cbe5dcd3fbb4c135c3ec9383166fa1494ab8a3bd81e93fb87a"
    sha256 cellar: :any,                 x86_64_linux:  "a2c364fbdcc994fc9064fd1847a25565f5a43ee76f675dbc101ab356fab6e5d5"
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
