class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.3.5.tar.gz"
  sha256 "c196fe15022492d3806f12459b8ab7d63f11599966860ffd541446c43b66dad4"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "fbb0d4b0fec771aaba0771605f04755067e7a399afbe15788e5f89536f17e218"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "66e469715d0bf4d4bd7d6e992026d7717f22781bff0bd22a02f85aa00d88bcc6"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "037205edfe4315bfc85c169a46b2b08683eb322a18f8654b7645eab00a2e7033"
    sha256 cellar: :any,                 x86_64_linux:  "dba77d6c7865051eb64a7a18527b475b62635fff6bd33817ff4bdbe9338ed592"
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
