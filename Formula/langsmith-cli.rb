class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.2.59.tar.gz"
  sha256 "476e3291f52a9e84e39f0c02fbd95b37a0825561a9bc4491e693dbf83aa905f9"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f166fd14252fbd5704bc57b80f7937e194f6dbdb9b543aae83c47ec3d972e41a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0ec79665983394bfa39b66b5c2cf9fe2ee5c4db638c28acf2605d35d9d58beb5"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "989ed2f253f61f0989b2d2d621d74b856cf60bd75f182c932bb95b4e12d3fe58"
    sha256 cellar: :any,                 x86_64_linux:  "1e9bb303d8424ea74aed1255169e89cad9313cfa41ebdec0b530c021f9104a3a"
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
