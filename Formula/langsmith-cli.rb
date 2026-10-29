class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.3.12.tar.gz"
  sha256 "f264023426e40cd7817fec8d1089f76739088957725ef1160524bd4f4a4295fd"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "384713f56de3dffa9deeef221645d3fd5f32bca0b6fd5a0d4e1429e30f434cb4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a2d02d45a6086649aaf20d592f2f4890363ffb1faf494d5a1c26e2c35c223c2d"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "619ae4ce68731f4292af999f9ef97f1ad04b04c821d3c292a1f93b2966948386"
    sha256 cellar: :any,                 x86_64_linux:  "4d857fa162466e4cf5ef0f545583a58d9e458f03eb69e6e835a48175c97be543"
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
