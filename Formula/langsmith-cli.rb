class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.5.1.tar.gz"
  sha256 "e1e6ecf23920750ec200274d6a4c5bebe1c6924e1bfa5d990cd60bf1f9f7675d"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "cd76b4423f2199288d32db32ae59f19b1fa506ef520ea8f99bfa8d33e37c485c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b3c394c3b0b75dc102bebff65a10666854bcbee55c3156aece4a3165b078c1ac"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "3ad7a6454e8cd30fe7dc6d7deca6b6643fe1f4a63a8282c7878a3022a3938c8c"
    sha256 cellar: :any,                 x86_64_linux:  "24d670cfad06e341d9205bab4ad56a6a69e0b2a7907195a2c2c25581bbda8a8d"
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
