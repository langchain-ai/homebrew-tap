class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.3.6.tar.gz"
  sha256 "863736bcceb8c9fe2e4fc652f60fbfb7c8740db12cd8c7b21f7656b9f1c9d676"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "0ec32fbecf47a434dc58591a917262b24c6df11809e8efafa6e4b463557b61a2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "935f54596d11c1857090dd6fab3ed253f0c2624d273f28776eecfc582604c510"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "efdfe859f724c5c21ce96a3b7c168a6e78ccd99dc8768446d9dbbd2b99dd477f"
    sha256 cellar: :any,                 x86_64_linux:  "9b446cf0232b1c498c61db5a345de2ea393b89a86e7e30abcb924976763e2920"
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
