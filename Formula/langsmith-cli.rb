class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.3.9.tar.gz"
  sha256 "5a81230f11ed054371fbe6f56778dc00b21d283a0ae02d51c5ada01b9d607e7f"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "67b1357f26765b59c4c6dbee50ab98483f91f9670f2f0295423d84f86ba25554"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "258331b32f44a50cdc2b750d7d17aa4ace9f82d1753ff00f036e053a44235c9f"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "c7f5b1e63c86c0cb60d85ef25f2b42609aa762cd94bb3e3a250ff6f132516bc3"
    sha256 cellar: :any,                 x86_64_linux:  "ec324627fbb0537dd6c2d24a68c11d878e16e7f66c8af38acccddf0357319f21"
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
