class LangsmithCli < Formula
  desc "Agent-first CLI for querying and managing LangSmith resources"
  homepage "https://github.com/langchain-ai/langsmith-cli"
  url "https://github.com/langchain-ai/langsmith-cli/archive/refs/tags/v0.3.2.tar.gz"
  sha256 "e8109e606356d6c0b695467e22128e4d1e0dae1da0dcf7b1ea812f2f9c45c1d9"
  license "MIT"
  head "https://github.com/langchain-ai/langsmith-cli.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/langchain-ai/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "bfc9a270bb7ed035356c4ed34b93d67c1a7733896dda80730a37c4982c14e3b4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "65a0ca61f30353d9da398f77c4c49d4515b55d71f6671e80ebabd8ee9b0b0759"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "fb005ad0d0bf168fb7d7d30b4f66c74f1a3590e3c5e1d1a79195669e9e9aab40"
    sha256 cellar: :any,                 x86_64_linux:  "3590b793273a84710ec0c554fb7fe971c0d114a42540e98da634bd9ab83c17aa"
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
