class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.3.11.tar.gz"
  sha256 "1bdc7d89a067658d951d2d4cb7c543262709ba36c589adae1a64b9c741a32e1a"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "e36a27838b189f13377e23e50cb8b6470d6dd84c7b6a6f590fda1b70dec22e6a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a3667939560d1ba272c968b59de17aa86684c90690ac3de70c8b67ad57300807"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "399d09d9113659d11849a6173092833e9c2912366e611a4d34df4d9aa24a1b41"
    sha256 cellar: :any,                 x86_64_linux:  "b30eca58ce2eee7e01dbb25abb7a1e73cd55f35c20e9431ce6bdf4afd7ef43e3"
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
