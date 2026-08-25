class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.2.51.tar.gz"
  sha256 "94fae93e56735fd3f9d358e05820659312753662b2ceac26aef3ad2864eafef6"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "841bea798df8650997c74642713641ba43c78edb466c376bf68677d198fa2358"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e3601e1a401a17da44c4d1994d80c738f381663081d03f46a3f92925c8e15a32"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "18d79fea392b543e613f646e69d95812072af2c579a3f9c84afbf64fa5122ef1"
    sha256 cellar: :any,                 x86_64_linux:  "404d35a1847ef7ccdce9ff690484254a0ef1e0f9004c0b264cf49f355a77abf5"
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
