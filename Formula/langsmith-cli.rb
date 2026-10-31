class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.3.13.tar.gz"
  sha256 "bf5ac7174f0f91aa7638bb5225c1460e7c87f2c8fb39aa7f9129ba859e15de4d"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f552a989fe87d674c575064a84c1fbe7579e807b35a03343518f9c768d83298e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b1b3b3f81143a4e7f2d5d989956c11278010e7c9e4a19879e29cd01f175c0d46"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "66ae34d8dfe5bd60fedfd160ebe881f40fa0bd198b0741bb256675887c02a104"
    sha256 cellar: :any,                 x86_64_linux:  "09e474509d7b5e8969e8d118eadcc83ab102720a6ddb1cee18e24d2e17c91035"
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
