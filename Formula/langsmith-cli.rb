class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.3.7.tar.gz"
  sha256 "58ecdf983bc8984298337d9c194934ec973fccb5dbc8288c7fec86d1bc133de9"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c0bc27af6aa245bd24291b7e344fa8b81acfe715c8892140f03a43da61aec4b4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b43ee661dd70f66663408a968dd669a89604d3a30ec22a39061494c06b73a008"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "c0e0d940d561b8752aeab97812fea75c64efe0d77574f28c2b852b0d218d326b"
    sha256 cellar: :any,                 x86_64_linux:  "2e821dba7a5eadecfaa855f042228715aefce6b27c1e978a2f5a93444c5657c1"
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
