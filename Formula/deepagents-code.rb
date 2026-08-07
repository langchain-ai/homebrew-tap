# WORK IN PROGRESS - known limitations of this packaging approach:
#
# 1. Provider extras and the in-app `/install`, `/update`, and auto-update
#    commands do NOT work under Homebrew. They operate by re-running
#    `uv tool install` to mutate a uv-managed environment; a Homebrew keg is
#    immutable, so dcode's detect_install_method() returns "brew" and
#    refuses. Only the providers baked into this formula are usable (the base
#    set: OpenAI, Anthropic, Gemini). Users who need other providers must use
#    the upstream installer: `uv tool install 'deepagents-code[<extra>]'`. To
#    ship a different baked-in set, regenerate with the desired extras.
#
# 2. macOS is arm64-only: cryptography (a transitive dependency) ships no
#    x86_64 macOS wheel for this version, so Intel macOS would need a source
#    build. Linux x86_64/arm64 and macOS arm64 are covered.
#
# 3. Prebuilt wheels bypass Homebrew's source-build (--no-binary) policy, so
#    this is NOT acceptable into homebrew-core - it is valid only in this
#    personal tap. It relies on `preserve_rpath` so Homebrew does not rewrite
#    the wheels' .so dylib IDs (which overflow the Mach-O header).
#
# 4. Maintenance: every transitive wheel is pinned by URL + sha256 at one
#    resolved version. Version bumps must be regenerated with
#    scripts/regen_deepagents_code.py (transitive deps re-resolve each time).
#
# 5. No bottle yet: each install runs the offline uv step (~12s). Routing a
#    bump through a PR builds/pulls bottles via tests.yml + publish.yml.

class DeepagentsCode < Formula
  include Language::Python::Virtualenv

  desc "Terminal coding agent (dcode) for Deep Agents"
  homepage "https://github.com/langchain-ai/deepagents"
  url "https://files.pythonhosted.org/packages/0f/69/a6c6319e4b9e15f14efdde4752d00db81d1921ec7297f8d75596fc2802ef/deepagents_code-0.1.54-py3-none-any.whl", using: :nounzip
  sha256 "fbfd0fc31caf5a8b0f1ff4ddea4da0de7837b0ffd3e6a222118c6480c99671ae"
  license "MIT"

  # Installs from prebuilt PyPI wheels via uv - no source compilation.
  depends_on "uv" => :build
  depends_on "libyaml"
  depends_on "python@3.13"

  # Native (compiled) wheels - one per OS/CPU architecture.
  on_macos do
    # macOS is arm64-only: cryptography (a transitive dependency) publishes no
    # x86_64 macOS wheel, so x86_64 macOS would have to build it from source.
    depends_on arch: :arm64

    on_arm do
      resource "bsdiff4" do
        url "https://files.pythonhosted.org/packages/d8/4c/825a16932605d305501ed144ae5567a3dc90c9164a393c61cc0ed68df3f0/bsdiff4-1.2.6-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "ee4417341712a4bf736694ce9ad3902b8c6fbd3425aadca44df9b66a51bbefa4"
      end

      resource "cffi" do
        url "https://files.pythonhosted.org/packages/55/41/4c7042f317b9217502988f0873af87e16ad606dc20f84e546e3e6ce9764c/cffi-2.1.1-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "19ee6127ee34de7d83ce3d371ebc5ed91addbdcc39f9ab15ce4eb35a4e534971"
      end

      resource "charset-normalizer" do
        url "https://files.pythonhosted.org/packages/b2/06/97ec2aeae780b31d742b6352218b43841a6871e2564578ca522dce4a45c3/charset_normalizer-3.4.9-cp313-cp313-macosx_10_13_universal2.whl"
        sha256 "440eede837960000d74978f0eba527be106b5b9aee0daf779d395276ed0b0614"
      end

      resource "cryptography" do
        url "https://files.pythonhosted.org/packages/c5/5c/59086b4aac5e879d38ddbcf74e4be7ade89cebc3eb199a55da998c3bb46a/cryptography-50.0.0-cp311-abi3-macosx_11_0_arm64.whl"
        sha256 "031e2d5dd4bb9caa3ca9c82e5a197fd8ae680232cee62603d1a813f3f07e3d03"
      end

      resource "grpcio" do
        url "https://files.pythonhosted.org/packages/04/19/21a9806eb8240e174fd1ab0cd5b9aa948bb0e05c2f2f55f9d5d7405e6d08/grpcio-1.80.0-cp313-cp313-macosx_11_0_universal2.whl"
        sha256 "92d787312e613754d4d8b9ca6d3297e69994a7912a32fa38c4c4e01c272974b0"
      end

      resource "grpcio-tools" do
        url "https://files.pythonhosted.org/packages/57/5a/c8a05b32bd7203f1b9f4c0151090a2d6179d6c97692d32f2066dc29c67a6/grpcio_tools-1.80.0-cp313-cp313-macosx_11_0_universal2.whl"
        sha256 "a447f28958a8fe84ff0d9d3d9473868feb27ee4a9c9c805e66f5b670121cec59"
      end

      resource "httptools" do
        url "https://files.pythonhosted.org/packages/5e/e5/8cfcabc5546e8022f168be28bcdaa128a240a0befdd03b59d558b4f18bd6/httptools-0.8.0-cp313-cp313-macosx_10_13_universal2.whl"
        sha256 "614ceea8ea606848bece2338ac03b3ce5324bcb4be8dc7d377ed708012fa4db8"
      end

      resource "jiter" do
        url "https://files.pythonhosted.org/packages/d0/2b/c3eaf16f5d7c9bad66ea32f40a95bd169b29a91217fcc7f081375157e99c/jiter-0.16.0-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "d28bb3c26762358dadf3e5bf0bccd29ae987d65e6988d2e6f49829c76b003c09"
      end

      resource "jsonschema-rs" do
        url "https://files.pythonhosted.org/packages/47/59/57efa11b8a7069687c7d741849a75092cbb4a6bdce30d52a2832a168c3c5/jsonschema_rs-0.44.1-cp310-abi3-macosx_10_12_x86_64.macosx_11_0_arm64.macosx_10_12_universal2.whl"
        sha256 "6f8be6467ee403e126e4e0abb68f13cfbf7199db54d5a4c0f2a1b00e1304f2e3"
      end

      resource "orjson" do
        url "https://files.pythonhosted.org/packages/32/33/93fcc25907235c344ae73122f8a4e01d2d393ef062b4af7d2e2487a32c37/orjson-3.11.9-cp313-cp313-macosx_10_15_x86_64.macosx_11_0_arm64.macosx_10_15_universal2.whl"
        sha256 "4bab1b2d6141fe7b32ae71dac905666ece4f94936efbfb13d55bb7739a3a6021"
      end

      resource "ormsgpack" do
        url "https://files.pythonhosted.org/packages/eb/29/bb0eba3288c0449efbb013e9c6f58aea79cf5cb9ee1921f8865f04c1a9d7/ormsgpack-1.12.2-cp313-cp313-macosx_10_12_x86_64.macosx_11_0_arm64.macosx_10_12_universal2.whl"
        sha256 "5ea60cb5f210b1cfbad8c002948d73447508e629ec375acb82910e3efa8ff355"
      end

      resource "pillow" do
        url "https://files.pythonhosted.org/packages/10/76/8803c13605b763d33d156c4678fc77f8443389c0c51c8aef707bb02015f4/pillow-12.3.0-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "d69141514cc30b774ceea5e3ed3a6635c8d8a96edf664689b890f4089111fb35"
      end

      resource "protobuf" do
        url "https://files.pythonhosted.org/packages/5c/01/a3c3ed5cd186f39e7880f8303cc51385a198a81469d53d0fdecf1f64d929/protobuf-6.33.6-cp39-abi3-macosx_10_9_universal2.whl"
        sha256 "9720e6961b251bde64edfdab7d500725a2af5280f3f4c87e57c0208376aa8c3a"
      end

      resource "pydantic-core" do
        url "https://files.pythonhosted.org/packages/c1/81/4fa520eaffa8bd7d1525e644cd6d39e7d60b1592bc5b516693c7340b50f1/pydantic_core-2.46.4-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "c94f0688e7b8d0a67abf40e57a7eaaecd17cc9586706a31b76c031f63df052b4"
      end

      resource "pyyaml" do
        url "https://files.pythonhosted.org/packages/b1/16/95309993f1d3748cd644e02e38b75d50cbc0d9561d21f390a76242ce073f/pyyaml-6.0.3-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "2283a07e2c21a2aa78d9c4442724ec1eb15f5e42a723b99cb3d822d48f5f7ad1"
      end

      resource "regex" do
        url "https://files.pythonhosted.org/packages/5d/3d/84165e4299ff76f3a40fe1f2abf939e976f693383a08d2beea6af62bd2c1/regex-2026.7.19-cp313-cp313-macosx_10_13_universal2.whl"
        sha256 "f035d9dc1d25eff9d361456572231c7d27b5ccd473ca7dc0adfce732bd006d40"
      end

      resource "rpds-py" do
        url "https://files.pythonhosted.org/packages/f3/6b/686d9dc4359a8f163cfbbf89ee0b4e586431de22fe8248edb63a8cf50d49/rpds_py-2026.6.3-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "f4d78253f6996be4901669ad25319f842f740eccf4d58e3c7f3dd39e6dde1d8f"
      end

      resource "sqlite-vec" do
        url "https://files.pythonhosted.org/packages/a4/3d/3677e0cd2f92e5ebc43cd29fbf565b75582bff1ccfa0b8327c7508e1084f/sqlite_vec-0.1.9-py3-none-macosx_11_0_arm64.whl"
        sha256 "1d52e30513bae4cc9778ddbf6145610434081be4c3afe57cd877893bad9f6b6c"
      end

      resource "textual-speedups" do
        url "https://files.pythonhosted.org/packages/fd/ab/af8eb2c53b65bd1f868109602ae11daac34d0889c80380b556f644793af5/textual_speedups-0.2.1-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "c762c60275dce06b9c9bde4173cefef950798877da0aac46538ccd0d2ffb2f43"
      end

      resource "tiktoken" do
        url "https://files.pythonhosted.org/packages/53/61/c68e123b6d753e3fc2751e9b18e732c9d8bf1e1926762e736eee935d931c/tiktoken-0.13.0-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "8fe806a50664e83a6ffd56cbd1e4f5dcc6cd32a3e7538f70dc38b1a271384545"
      end

      resource "uuid-utils" do
        url "https://files.pythonhosted.org/packages/d2/dd/614fb9912157ac0128e6050859ccf06d9f13df9a944a803e8f80f6157e38/uuid_utils-0.17.0-cp313-cp313-macosx_10_12_x86_64.macosx_11_0_arm64.macosx_10_12_universal2.whl"
        sha256 "d11a7bc1e02da8984d32e6de9e0826c6edac00eac17de270f372bf32f9a0af63"
      end

      resource "uvloop" do
        url "https://files.pythonhosted.org/packages/89/8c/182a2a593195bfd39842ea68ebc084e20c850806117213f5a299dfc513d9/uvloop-0.22.1-cp313-cp313-macosx_10_13_universal2.whl"
        sha256 "561577354eb94200d75aca23fbde86ee11be36b00e52a4eaf8f50fb0c86b7705"
      end

      resource "wasmtime" do
        url "https://files.pythonhosted.org/packages/dc/b2/fc660c451b7969a9eef8d35f505837ffc8e8a21064f18255a8f0347c1318/wasmtime-47.0.1-py3-none-macosx_11_0_arm64.whl"
        sha256 "58da69f71750e844e32614c1805246ffca4c8b032d46a8145faa26c228c6c5ac"
      end

      resource "watchfiles" do
        url "https://files.pythonhosted.org/packages/31/3a/0da302f2307aee316922806ebd5726c542cbd787c938271cf14a074c7daf/watchfiles-1.2.0-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "7ba0480b9a74af058f43b337e937a451e109295c420916d68ad24e3dc02f5e44"
      end

      resource "websockets" do
        url "https://files.pythonhosted.org/packages/cb/9f/51f0cf64471a9d2b4d0fc6c534f323b664e7095640c34562f5182e5a7195/websockets-15.0.1-cp313-cp313-macosx_10_13_universal2.whl"
        sha256 "ee443ef070bb3b6ed74514f5efaa37a252af57c90eb33b956d35c8e9c10a1931"
      end

      resource "xxhash" do
        url "https://files.pythonhosted.org/packages/07/3f/5072f1f0f5714186f0ac2a0b5a4929ce30d4b845e94886b6c01b6ebda0be/xxhash-3.8.1-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "bcab50a389cc04d87f90092af78a6adba2ab3deca63175a3344ca83514045315"
      end

      resource "zstandard" do
        url "https://files.pythonhosted.org/packages/3f/06/9ae96a3e5dcfd119377ba33d4c42a7d89da1efabd5cb3e366b156c45ff4d/zstandard-0.25.0-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "a1a4ae2dec3993a32247995bdfe367fc3266da832d82f8438c8570f989753de1"
      end
    end
  end

  on_linux do
    on_arm do
      resource "bsdiff4" do
        url "https://files.pythonhosted.org/packages/c2/e2/0cf538a786f47b08e26f3970a6f98c2b7b9d555c01e085425282944a2c7f/bsdiff4-1.2.6-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "39ddfa2137de44c9743a611d71d263d0cc8c45e5b18ee84ca5ff6b6240be1740"
      end

      resource "cffi" do
        url "https://files.pythonhosted.org/packages/37/6f/3b5ce4c3b2192d250f04908f2bfd91ef34552ec8f7716a5d4abdb8d67bb2/cffi-2.1.1-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.whl"
        sha256 "f16c709686a78c727bbbf059f92b0bf41c6fc60deec706d2dc19f529175a6125"
      end

      resource "charset-normalizer" do
        url "https://files.pythonhosted.org/packages/d0/39/8ff066c672434225f8d25f8b739f992af250944392173dcc88362681c9bf/charset_normalizer-3.4.9-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "21e764fd1e70b6a3e205a0e46f3051701f98a8cb3fad66eeb80e48bb502f8698"
      end

      resource "cryptography" do
        url "https://files.pythonhosted.org/packages/57/ef/8f2df13c7216bcad3e1c74e07f6e193d93e998e114f524a53877c9af27ad/cryptography-50.0.0-cp311-abi3-manylinux2014_aarch64.manylinux_2_17_aarch64.whl"
        sha256 "fd9192b7b70c573d7f214eb1ae35e00d359f6f5e4b27c7e21e30de1fc6204645"
      end

      resource "grpcio" do
        url "https://files.pythonhosted.org/packages/18/3a/23347d35f76f639e807fb7a36fad3068aed100996849a33809591f26eca6/grpcio-1.80.0-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.whl"
        sha256 "8ac393b58aa16991a2f1144ec578084d544038c12242da3a215966b512904d0f"
      end

      resource "grpcio-tools" do
        url "https://files.pythonhosted.org/packages/82/6b/794350ed645c12c310008f97068f6a6fd927150b0d0d08aad1d909e880b1/grpcio_tools-1.80.0-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.whl"
        sha256 "75f00450e08fe648ad8a1eeb25bc52219679d54cdd02f04dfdddc747309d83f6"
      end

      resource "httptools" do
        url "https://files.pythonhosted.org/packages/77/00/258bfc0837221f81d9725c45f9b948a6a6b2994a147a4fb66e85100c668f/httptools-0.8.0-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "88bdd940f2b5d487b4d032c6afa5489a7dc4694410d43de3c38c4fb3af0dc45d"
      end

      resource "jiter" do
        url "https://files.pythonhosted.org/packages/96/3f/02fdfc6705cad96127d883af5c34e4867f554f29ec7705ec1a46156400a9/jiter-0.16.0-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "0542a7189c26920778658fc8fcf2af8bae05bae9924577f71804acef37996536"
      end

      resource "jsonschema-rs" do
        url "https://files.pythonhosted.org/packages/a8/19/6475da01b4e81c0445698290a7b8f237e678a0dc9fbf55df663243597b70/jsonschema_rs-0.44.1-cp310-abi3-manylinux_2_28_aarch64.whl"
        sha256 "502af60c802cf149185ea01edbd31a143b09aaf06b27b6422f8b8893984b1998"
      end

      resource "orjson" do
        url "https://files.pythonhosted.org/packages/21/0f/c9ede0bf052f6b4051e64a7d4fa91b725cccf8321a6a786e86eb03519f00/orjson-3.11.9-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "ffe02797b5e9f3a9d8292ddcd289b474ad13e81ad83cd1891a240811f1d2cb81"
      end

      resource "ormsgpack" do
        url "https://files.pythonhosted.org/packages/6e/31/5efa31346affdac489acade2926989e019e8ca98129658a183e3add7af5e/ormsgpack-1.12.2-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "f3601f19afdbea273ed70b06495e5794606a8b690a568d6c996a90d7255e51c1"
      end

      resource "pillow" do
        url "https://files.pythonhosted.org/packages/1f/01/e18aff37cb0b4aac47ac90f016d347a49aca667ef97f190b06ac2aabc928/pillow-12.3.0-cp313-cp313-manylinux_2_27_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "f7401aebd7f581d7f83a439d87d474999317ee099218e5ad25d125290990ba65"
      end

      resource "protobuf" do
        url "https://files.pythonhosted.org/packages/ee/90/b3c01fdec7d2f627b3a6884243ba328c1217ed2d978def5c12dc50d328a3/protobuf-6.33.6-cp39-abi3-manylinux2014_aarch64.whl"
        sha256 "e2afbae9b8e1825e3529f88d514754e094278bb95eadc0e199751cdd9a2e82a2"
      end

      resource "pydantic-core" do
        url "https://files.pythonhosted.org/packages/03/d5/fd02da45b659668b05923b17ba3a0100a0a3d5541e3bd8fcc4ecb711309e/pydantic_core-2.46.4-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "f027324c56cd5406ca49c124b0db10e56c69064fec039acc571c29020cc87c76"
      end

      resource "pyyaml" do
        url "https://files.pythonhosted.org/packages/50/31/b20f376d3f810b9b2371e72ef5adb33879b25edb7a6d072cb7ca0c486398/pyyaml-6.0.3-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "ee2922902c45ae8ccada2c5b501ab86c36525b883eff4255313a253a3160861c"
      end

      resource "regex" do
        url "https://files.pythonhosted.org/packages/07/cd/42dfbabff3dfc9603c501c0e2e2c5adbb09d127b267bf5348de0af338c15/regex-2026.7.19-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "0c41c63992bf1874cebb6e7f56fd7d3c007924659a604ae3d90e427d40d4fd13"
      end

      resource "rpds-py" do
        url "https://files.pythonhosted.org/packages/9e/9b/069aa329940f8207615e091f5eedbbd40e1e15eac68a0790fd05ccdf796c/rpds_py-2026.6.3-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "54f45a148e28767bf343d33a684693c70e451c6f4c0e9904709a723fafbdfc1f"
      end

      resource "sqlite-vec" do
        url "https://files.pythonhosted.org/packages/00/d4/f2b936d3bdc38eadcbd2a87875815db36430fab0363182ba5d12cd8e0b51/sqlite_vec-0.1.9-py3-none-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "4e921e592f24a5f9a18f590b6ddd530eb637e2d474e3b1972f9bbeb773aa3cb9"
      end

      resource "textual-speedups" do
        url "https://files.pythonhosted.org/packages/9a/d8/aab66c0401118633ac3121d4f79695e86d37aae3b2ebd49a626d034ba64e/textual_speedups-0.2.1-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "42172f4b7742988d9ff28098600b8a4a86a7e86ba39fcc3c779a93b98ef31abc"
      end

      resource "tiktoken" do
        url "https://files.pythonhosted.org/packages/ef/8b/96cc178cc584e65d363134500f297790b06cd48cdeb1e8fcf7bbe60f4715/tiktoken-0.13.0-cp313-cp313-manylinux_2_28_aarch64.whl"
        sha256 "125bc05005e747f993a83dc67934249932d6e4209854452cd4c0b1d53fba3ba2"
      end

      resource "uuid-utils" do
        url "https://files.pythonhosted.org/packages/18/6d/8a63e5eb2d5a6ba69a6c2036e305075bd6f5a022e7ea25fc6ce0eb7c51d2/uuid_utils-0.17.0-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "32df1944808877702ceea398c103881c09a679bb672a215e01c2a84231266bf9"
      end

      resource "uvloop" do
        url "https://files.pythonhosted.org/packages/b7/02/654426ce265ac19e2980bfd9ea6590ca96a56f10c76e63801a2df01c0486/uvloop-0.22.1-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "6e2ea3d6190a2968f4a14a23019d3b16870dd2190cd69c8180f7c632d21de68d"
      end

      resource "wasmtime" do
        url "https://files.pythonhosted.org/packages/d7/93/f12469c859fed8332961c4efa68c1f1981542b9ce95248b617255938a55d/wasmtime-47.0.1-py3-none-manylinux2014_aarch64.whl"
        sha256 "4f72162ceed1d50de8226fac6b12e1ecce54883a0c3f7355bb141eae40df488a"
      end

      resource "watchfiles" do
        url "https://files.pythonhosted.org/packages/db/ef/d5bdb705c224dbc256aa0c1ec47bf4e61ec52558f2afb44a71a1fe4d7015/watchfiles-1.2.0-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "4f34e26a19f91f710c08e0183429f0d1d15df734e6bc78c31e77b9ea9c433658"
      end

      resource "websockets" do
        url "https://files.pythonhosted.org/packages/31/1d/063b25dcc01faa8fada1469bdf769de3768b7044eac9d41f734fd7b6ad6d/websockets-15.0.1-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "595b6c3969023ecf9041b2936ac3827e4623bfa3ccf007575f04c5a6aa318c22"
      end

      resource "xxhash" do
        url "https://files.pythonhosted.org/packages/99/a8/e10488efd31fcb13fcd6acbc6e788f10c6f8e3a0cc4ae3eb89dc19c55a12/xxhash-3.8.1-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "32ab1e5432690276e71192be7401b55f96db2d0eedea5d44eb1f164505669cc0"
      end

      resource "zstandard" do
        url "https://files.pythonhosted.org/packages/6d/db/ddb11011826ed7db9d0e485d13df79b58586bfdec56e5c84a928a9a78c1c/zstandard-0.25.0-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.whl"
        sha256 "bfc4e20784722098822e3eee42b8e576b379ed72cca4a7cb856ae733e62192ea"
      end
    end

    on_intel do
      resource "bsdiff4" do
        url "https://files.pythonhosted.org/packages/5a/1e/7027849a6dc02b580e352b1528899053bd919029b185fbaa14c6f268180b/bsdiff4-1.2.6-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "46313f0eb8f63efb54a3c4219cd7b5b8a7795012b535f9d0838fe3f2b3349849"
      end

      resource "cffi" do
        url "https://files.pythonhosted.org/packages/95/95/86342356ff5953b3fb06f7ef7c5bee212d45e770abc7218d451b9148313c/cffi-2.1.1-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
        sha256 "a931079504ecc49efed7744c476a5c343a92fabf66dec2db95edb1b2fdc770e2"
      end

      resource "charset-normalizer" do
        url "https://files.pythonhosted.org/packages/ea/f8/72eb13dcabe7257035cea8aefd922caad2f110d252bf9f67c4c2ca763aee/charset_normalizer-3.4.9-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "84fd18bcc17526fc2b3c1af7d2b9217d32c9c04448c16ec693b9b4f1985c3d33"
      end

      resource "cryptography" do
        url "https://files.pythonhosted.org/packages/d9/41/029086c34d91052fc3b88bcc8056f709a7c915c7a23b235a54eb800b1c97/cryptography-50.0.0-cp311-abi3-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
        sha256 "06a32a980526a6ab9a4b9bf8f7385800791e2bb960903cb6b530e4817509a3b7"
      end

      resource "grpcio" do
        url "https://files.pythonhosted.org/packages/9b/e2/da1506ecea1f34a5e365964644b35edef53803052b763ca214ba3870c856/grpcio-1.80.0-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
        sha256 "873ff5d17d68992ef6605330127425d2fc4e77e612fa3c3e0ed4e668685e3140"
      end

      resource "grpcio-tools" do
        url "https://files.pythonhosted.org/packages/10/f3/abe089b058f87f9910c9a458409505cbeb0b3e1c2d993a79721d02ee6a32/grpcio_tools-1.80.0-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
        sha256 "7982b5fe42f012686b667dda12916884de95c4b1c65ff64371fb7232a1474b23"
      end

      resource "httptools" do
        url "https://files.pythonhosted.org/packages/2e/1b/46f1cecf06b9bbde8e4b8c88034ac7908989e5ff7a3a388ef38392949c1f/httptools-0.8.0-cp313-cp313-manylinux1_x86_64.manylinux_2_28_x86_64.manylinux_2_5_x86_64.whl"
        sha256 "eb3028cca2fc0a6d720e52ef61d8ebb62fcbfeb1de56874546d858d3f25a26b7"
      end

      resource "jiter" do
        url "https://files.pythonhosted.org/packages/0f/94/db768b6938e0df35c86beeba3dfbbb025c9ee5c19e1aa271f2396e50864d/jiter-0.16.0-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "c682bea068a90b764577bdb78a60a4c1d1606daf9cd4c893832a37c7cc9d9026"
      end

      resource "jsonschema-rs" do
        url "https://files.pythonhosted.org/packages/35/a9/6d750088795947a5366cdfa6b9064680a3b0a86f61806521beb35d88c8fb/jsonschema_rs-0.44.1-cp310-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "8078c834c3cea6303796fc4925bb8646d1f68313bd54f6d3dde08c8b8eb74bc1"
      end

      resource "orjson" do
        url "https://files.pythonhosted.org/packages/a1/08/dca0082dd2a194acb93e5457e73455388e2e2ca464a2672449a9ddbb679d/orjson-3.11.9-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "4e39364e726a8fff737309aff059ff67d8a8c8d5b677be7bb49a8b3e84b7e218"
      end

      resource "ormsgpack" do
        url "https://files.pythonhosted.org/packages/1c/a2/072343e1413d9443e5a252a8eb591c2d5b1bffbe5e7bfc78c069361b92eb/ormsgpack-1.12.2-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "39c1bd2092880e413902910388be8715f70b9f15f20779d44e673033a6146f2d"
      end

      resource "pillow" do
        url "https://files.pythonhosted.org/packages/f7/62/de5bdd77d935331f4f802edc11e4d82950f642caad6cb2f949837b8560e2/pillow-12.3.0-cp313-cp313-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "0847a763afefb695bc912d7c131e7e0632d4edc1d8698f58ddabec8e46b8b6d3"
      end

      resource "protobuf" do
        url "https://files.pythonhosted.org/packages/16/92/d1e32e3e0d894fe00b15ce28ad4944ab692713f2e7f0a99787405e43533a/protobuf-6.33.6-cp39-abi3-manylinux2014_x86_64.whl"
        sha256 "e9db7e292e0ab79dd108d7f1a94fe31601ce1ee3f7b79e0692043423020b0593"
      end

      resource "pydantic-core" do
        url "https://files.pythonhosted.org/packages/07/f8/41db9de19d7987d6b04715a02b3b40aea467000275d9d758ffaa31af7d50/pydantic_core-2.46.4-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "9551187363ffc0de2a00b2e47c25aeaeb1020b69b668762966df15fc5659dd5a"
      end

      resource "pyyaml" do
        url "https://files.pythonhosted.org/packages/74/27/e5b8f34d02d9995b80abcef563ea1f8b56d20134d8f4e5e81733b1feceb2/pyyaml-6.0.3-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "0f29edc409a6392443abf94b9cf89ce99889a1dd5376d94316ae5145dfedd5d6"
      end

      resource "regex" do
        url "https://files.pythonhosted.org/packages/2a/be/ff61f28f9273658cfe23acbbac5217221f6519960ed401e61dfdab12bc35/regex-2026.7.19-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "c0d702548d89d572b2929879bc883bb7a4c4709efafe4512cadee56c55c9bd15"
      end

      resource "rpds-py" do
        url "https://files.pythonhosted.org/packages/57/d7/fe978efc2ae50abe48eb7464668ea99f53c010c60aeebb7b35ad27f23661/rpds_py-2026.6.3-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "acac386b453c2516111b50985d60ce46e7fadb5ea71ae7b25f4c946935bf27cf"
      end

      resource "sqlite-vec" do
        url "https://files.pythonhosted.org/packages/6f/ad/6afd073b0f817b3e03f9e37ad626ae341805891f23c74b5292818f49ac63/sqlite_vec-0.1.9-py3-none-manylinux_2_17_x86_64.manylinux2014_x86_64.manylinux1_x86_64.whl"
        sha256 "1515727990b49e79bcaf75fdee2ffc7d461f8b66905013231251f1c8938e7786"
      end

      resource "textual-speedups" do
        url "https://files.pythonhosted.org/packages/65/45/38a83d71467dab3e4dff6423ce2daa57da67032cfd918a6f697e31e6807c/textual_speedups-0.2.1-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "1389c87c4e1a071ba7ef0a2189d6989b753893ade56fea2e46bda5579f9e1844"
      end

      resource "tiktoken" do
        url "https://files.pythonhosted.org/packages/86/f5/bab735d2c72ea55404b295d02d092644eb5f7cc6205e34d35eb9abfb9ab2/tiktoken-0.13.0-cp313-cp313-manylinux_2_28_x86_64.whl"
        sha256 "5e6358911cab4adee6712da27d65573496a4f68cf8a2b5fca6a4ad10fc5748cf"
      end

      resource "uuid-utils" do
        url "https://files.pythonhosted.org/packages/d8/79/e8e0f8b3955f2081c116157119d87659937893242eb834aa170da04d660b/uuid_utils-0.17.0-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "09a55b7a5ae764985cb46467496a1787678d0a1400356157a080ad95b1a36869"
      end

      resource "uvloop" do
        url "https://files.pythonhosted.org/packages/15/c0/0be24758891ef825f2065cd5db8741aaddabe3e248ee6acc5e8a80f04005/uvloop-0.22.1-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "0530a5fbad9c9e4ee3f2b33b148c6a64d47bbad8000ea63704fa8260f4cf728e"
      end

      resource "wasmtime" do
        url "https://files.pythonhosted.org/packages/5e/ba/f321faaad1d616b94fe70a62ebb7e4054cfe41a6a46aa796ad2bb07fa08c/wasmtime-47.0.1-py3-none-manylinux1_x86_64.whl"
        sha256 "9724600b036c6e95c4fe952e29fad83b4f02bdc11d23f25c4ee3ffff2c1d7257"
      end

      resource "watchfiles" do
        url "https://files.pythonhosted.org/packages/a7/6c/89b1a230a78f57c52dd8893adb1f92f94411721b6ec12596c56d98c74356/watchfiles-1.2.0-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "ca148d73dea36c9763aaa351e4d7a51780ec1584217c45276f4fe8239c768b71"
      end

      resource "websockets" do
        url "https://files.pythonhosted.org/packages/ff/b2/83a6ddf56cdcbad4e3d841fcc55d6ba7d19aeb89c50f24dd7e859ec0805f/websockets-15.0.1-cp313-cp313-manylinux_2_5_x86_64.manylinux1_x86_64.manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "0f3c1e2ab208db911594ae5b4f79addeb3501604a165019dd221c0bdcabe4db8"
      end

      resource "xxhash" do
        url "https://files.pythonhosted.org/packages/29/83/e361d3c1acd1b21e1d489616de6fa4aaf843365d8179f612e3743eac20a9/xxhash-3.8.1-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "98ee81b4b7f3023c9cb04a78cc67610baffcb5812d92f2096cb5a5efc6f19437"
      end

      resource "zstandard" do
        url "https://files.pythonhosted.org/packages/63/4b/e3678b4e776db00f9f7b2fe58e547e8928ef32727d7a1ff01dea010f3f13/zstandard-0.25.0-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
        sha256 "8e735494da3db08694d26480f1493ad2cf86e99bdd53e8e9771b2752a5c0246a"
      end
    end
  end

  # Prebuilt wheels ship extension modules (.so) and bundled dylibs with @rpath
  # install names and no header padding. Keep those IDs as-is so Homebrew does
  # not try to rewrite them to absolute keg paths that overflow the Mach-O header.
  preserve_rpath

  # Pure-Python (py3-none-any) wheels - identical across all platforms.
  resource "agent-client-protocol" do
    url "https://files.pythonhosted.org/packages/9c/c7/b84b8698879464bd8f869551bac31454bed14a3a22910f65d9693f3701bd/agent_client_protocol-0.12.0-py3-none-any.whl"
    sha256 "233626748034896214de118f5cf5a319484ad2186705fd595219afee92237ccc"
  end

  resource "aiosqlite" do
    url "https://files.pythonhosted.org/packages/00/b7/e3bf5133d697a08128598c8d0abc5e16377b51465a33756de24fa7dee953/aiosqlite-0.22.1-py3-none-any.whl"
    sha256 "21c002eb13823fad740196c5a2e9d8e62f6243bd9e7e4a1f87fb5e44ecb4fceb"
  end

  resource "annotated-types" do
    url "https://files.pythonhosted.org/packages/99/91/8acff4f5e50511b911bbccb72b8628a49c68ce14148cd9f6431094859a90/annotated_types-0.8.0-py3-none-any.whl"
    sha256 "f072f4d804ea359e4eaf198b1af7a8b0943881a87f31bb764f8bf219bb9419e0"
  end

  resource "anthropic" do
    url "https://files.pythonhosted.org/packages/fa/91/b3d41643f1f639927e8c5fb02c3bd8bffe6f1f29e219b3bd4c61e267b15c/anthropic-0.121.0-py3-none-any.whl"
    sha256 "6048713fa441e59e1cba8363171cd2a86273b25bd213e9c7ac70a523af88b011"
  end

  resource "anyio" do
    url "https://files.pythonhosted.org/packages/da/35/f2287558c17e29fafc8ef3daf819bb9834061cfa43bff8014f7df7f63bdc/anyio-4.14.2-py3-none-any.whl"
    sha256 "9f505dda5ac9f0c8309b5e8bd445a8c2bf7246f3ce950121e45ea15bc41d1494"
  end

  resource "attrs" do
    url "https://files.pythonhosted.org/packages/64/b4/17d4b0b2a2dc85a6df63d1157e028ed19f90d4cd97c36717afef2bc2f395/attrs-26.1.0-py3-none-any.whl"
    sha256 "c647aa4a12dfbad9333ca4e71fe62ddc36f4e63b2d260a37a8b83d2f043ac309"
  end

  resource "beautifulsoup4" do
    url "https://files.pythonhosted.org/packages/88/c6/92fcd42f1ba33e1184263f25bfabf3d27c383410470f169e4b8163bf9c17/beautifulsoup4-4.15.0-py3-none-any.whl"
    sha256 "d6f88de62e1d4e38ecb1077eb9724cd0eff29d2a08ca16a401e9b9e93f117cf9"
  end

  resource "blockbuster" do
    url "https://files.pythonhosted.org/packages/95/c1/84fc6811122f54b20de2e5afb312ee07a3a47a328755587d1e505475239b/blockbuster-1.5.26-py3-none-any.whl"
    sha256 "f8e53fb2dd4b6c6ec2f04907ddbd063ca7cd1ef587d24448ef4e50e81e3a79bb"
  end

  resource "bracex" do
    url "https://files.pythonhosted.org/packages/b8/8f/6f7273a7adb8d73fc8d21ede4376a3e475e52f98435c6007f69100dec8ca/bracex-3.0.1-py3-none-any.whl"
    sha256 "6523ad83aeb5098a4ee597cff0f964442ff74e460bd3fafaffab6a013ff2288c"
  end

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/0b/a7/71ac2cff56fec219ed242bb11b8efb69fcc4bec75db06fb7bfe35de520e6/certifi-2026.7.22-py3-none-any.whl"
    sha256 "62f22742b58a1a33014a2b6b706588a8d7e2a88ae7bd1a6ebe8c992928483775"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/fb/e2/79c688af8b210d232694e31e59da9f6ec747bae31c3f5946e4e9b98860d5/click-8.4.2-py3-none-any.whl"
    sha256 "e6f9f66136c816745b9d65817da91d61d957fb16e02e4dcd0552553c5a197b76"
  end

  resource "cloudpickle" do
    url "https://files.pythonhosted.org/packages/88/39/799be3f2f0f38cc727ee3b4f1445fe6d5e4133064ec2e4115069418a5bb6/cloudpickle-3.1.2-py3-none-any.whl"
    sha256 "9acb47f6afd73f60dc1df93bb801b472f05ff42fa6c84167d25cb206be1fbf4a"
  end

  resource "croniter" do
    url "https://files.pythonhosted.org/packages/cd/ba/d678e5bd329646ca51d3c92addbc77804e86d21f4b6b6a027218e6abb010/croniter-6.2.4-py3-none-any.whl"
    sha256 "8ef3d544107a5c05a150a2d78f8bf5a8eb9c5c4d93405a736b824109574e3f4d"
  end

  resource "deepagents" do
    url "https://files.pythonhosted.org/packages/df/c9/d4778dd09aaeb03b9653bb2be8591f3b7179ec5757a467f46e97627bccca/deepagents-0.7.5-py3-none-any.whl"
    sha256 "a1be73d150929c5e826d67a05af6277748f25e4b53ae530b3fb1454df9e3ca95"
  end

  resource "deepagents-acp" do
    url "https://files.pythonhosted.org/packages/81/30/0e9ce37f54b9f45116a8c6aa0d6945a662edaf34e9dd5e30d6b986ab325d/deepagents_acp-0.0.9-py3-none-any.whl"
    sha256 "f6c4693e5b49bb01bef4217beb1aed044e0e548ffeaf4affa94599218450e999"
  end

  resource "distro" do
    url "https://files.pythonhosted.org/packages/12/b3/231ffd4ab1fc9d679809f356cebee130ac7daa00d6d6f3206dd4fd137e9e/distro-1.9.0-py3-none-any.whl"
    sha256 "7bffd925d65168f85027d8da9af6bddab658135b840670a223589bc0c8ef02b2"
  end

  resource "docstring-parser" do
    url "https://files.pythonhosted.org/packages/a7/5f/ed01f9a3cdffbd5a008556fc7b2a08ddb1cc6ace7effa7340604b1d16699/docstring_parser-0.18.0-py3-none-any.whl"
    sha256 "b3fcbed555c47d8479be0796ef7e19c2670d428d72e96da63f3a40122860374b"
  end

  resource "filelock" do
    url "https://files.pythonhosted.org/packages/60/02/be4a57b60c7149b55b9e3b3c13f609cd8eb5307c751f22bd8fb8d262e75b/filelock-3.29.7-py3-none-any.whl"
    sha256 "987db6f789a3a2a59f55081801b2b3697cb97e2a736b5f1a9e99b559285fbc51"
  end

  resource "filetype" do
    url "https://files.pythonhosted.org/packages/18/79/1b8fa1bb3568781e84c9200f951c735f3f157429f44be0495da55894d620/filetype-1.2.0-py2.py3-none-any.whl"
    sha256 "7ce71b6880181241cf7ac8697a2f1eb6a8bd9b429f7ad6d27b8db9ba5f1c2d25"
  end

  resource "genai-prices" do
    url "https://files.pythonhosted.org/packages/6e/5e/cfe36dff790ffad6aeff8a069b6f36743987ac17053579035ee0a67635dd/genai_prices-0.1.1-py3-none-any.whl"
    sha256 "de2e3d8ea3ca1d0d292025995c598da447a74e94f22cd3342df46941aeb5416b"
  end

  resource "google-auth" do
    url "https://files.pythonhosted.org/packages/bc/b3/6117b2f24065cd7e2c4f140e9a193e215f089ca8ba314cf91eb9d0b7fe0a/google_auth-2.56.3-py3-none-any.whl"
    sha256 "8ec438808f813ad034535000261eed1067475d229d05bbf4216e78c3f2362e53"
  end

  resource "google-genai" do
    url "https://files.pythonhosted.org/packages/b3/37/71e397a5b93d9a3c139e95acdcb00b4169ed59ae20e16616f2875170abb7/google_genai-2.17.0-py3-none-any.whl"
    sha256 "a4835563c60aee646c9c4b261c507aa4a624710d25017012d20dc65abf3d9a54"
  end

  resource "googleapis-common-protos" do
    url "https://files.pythonhosted.org/packages/9a/51/186c02b8549b69ccda44429cf6ff5081e4b61a602ddfe6a8020d1be31d1b/googleapis_common_protos-1.75.1-py3-none-any.whl"
    sha256 "28a1934bcd33b9c9da66ac301a0a4227e3367f095a17d0375cb98f0a09d93b79"
  end

  resource "grpcio-health-checking" do
    url "https://files.pythonhosted.org/packages/5e/d1/d97eb30386feff6ac2a662620e2ed68be352e9a182d62e06213db694906a/grpcio_health_checking-1.80.0-py3-none-any.whl"
    sha256 "d804d4549cbb71e90ca2c7bf0c501060135dfd220aca8e2c54f96d3e79e210e5"
  end

  resource "h11" do
    url "https://files.pythonhosted.org/packages/04/4b/29cac41a4d98d144bf5f6d33995617b185d14b22401f75ca86f384e87ff1/h11-0.16.0-py3-none-any.whl"
    sha256 "63cf8bbe7522de3bf65932fda1d9c2772064ffb3dae62d55932da54b31cb6c86"
  end

  resource "httpcore" do
    url "https://files.pythonhosted.org/packages/7e/f5/f66802a942d491edb555dd61e3a9961140fd64c90bce1eafd741609d334d/httpcore-1.0.9-py3-none-any.whl"
    sha256 "2d400746a40668fc9dec9810239072b40b4484b640a8c38fd654a024c7a1bf55"
  end

  resource "httpcore2" do
    url "https://files.pythonhosted.org/packages/9f/fb/46c52b781975c335a2bcf1072c7bbc007cbdc8d674217f5ee1daba2c848b/httpcore2-2.9.1-py3-none-any.whl"
    sha256 "6182472379e855fe4221246a2bb7ecede403bc61c6798062ae1787d051ccde26"
  end

  resource "httpx" do
    url "https://files.pythonhosted.org/packages/2a/39/e50c7c3a983047577ee07d2a9e53faf5a69493943ec3f6a384bdc792deb2/httpx-0.28.1-py3-none-any.whl"
    sha256 "d909fcccc110f8c7faf814ca82a9a4d816bc5a6dbfea25d6591d6985b8ba59ad"
  end

  resource "httpx-sse" do
    url "https://files.pythonhosted.org/packages/d2/fd/6668e5aec43ab844de6fc74927e155a3b37bf40d7c3790e49fc0406b6578/httpx_sse-0.4.3-py3-none-any.whl"
    sha256 "0ac1c9fe3c0afad2e0ebb25a934a59f4c7823b60792691f779fad2c5568830fc"
  end

  resource "httpx2" do
    url "https://files.pythonhosted.org/packages/13/b8/cfd91c4ab9134d386d48f0b6ac662ff3d4be6efdee59ee1c67ebc3c0487c/httpx2-2.9.1-py3-none-any.whl"
    sha256 "1820fe14a9ab1107bfeff39259987429450b070ec0ff38cc87eb0d8c97fdc71a"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/1e/5e/d4e9f1a599fb8e573b7b87160658329fbf28d19eac2718f51fc3def3aa5a/idna-3.18-py3-none-any.whl"
    sha256 "7f952cbe720b688055e3f87de14f5c3e5fdaa8bc3928985c4077ca689de849a2"
  end

  resource "importlib-metadata" do
    url "https://files.pythonhosted.org/packages/fa/5e/f8e9a1d23b9c20a551a8a02ea3637b4642e22c2626e3a13a9a29cdea99eb/importlib_metadata-8.7.1-py3-none-any.whl"
    sha256 "5a1f80bf1daa489495071efbb095d75a634cf28a8bc299581244063b53176151"
  end

  resource "jsonpatch" do
    url "https://files.pythonhosted.org/packages/73/07/02e16ed01e04a374e644b575638ec7987ae846d25ad97bcc9945a3ee4b0e/jsonpatch-1.33-py2.py3-none-any.whl"
    sha256 "0ae28c0cd062bbd8b8ecc26d7d164fbbea9652a1a3693f3b956c1eae5145dade"
  end

  resource "jsonpointer" do
    url "https://files.pythonhosted.org/packages/9e/6a/a83720e953b1682d2d109d3c2dbb0bc9bf28cc1cbc205be4ef4be5da709d/jsonpointer-3.1.1-py3-none-any.whl"
    sha256 "8ff8b95779d071ba472cf5bc913028df06031797532f08a7d5b602d8b2a488ca"
  end

  resource "jsonschema" do
    url "https://files.pythonhosted.org/packages/69/90/f63fb5873511e014207a475e2bb4e8b2e570d655b00ac19a9a0ca0a385ee/jsonschema-4.26.0-py3-none-any.whl"
    sha256 "d489f15263b8d200f8387e64b4c3a75f06629559fb73deb8fdfb525f2dab50ce"
  end

  resource "jsonschema-specifications" do
    url "https://files.pythonhosted.org/packages/41/45/1a4ed80516f02155c51f51e8cedb3c1902296743db0bbc66608a0db2814f/jsonschema_specifications-2025.9.1-py3-none-any.whl"
    sha256 "98802fee3a11ee76ecaca44429fda8a41bff98b00a0f2838151b113f210cc6fe"
  end

  resource "langchain" do
    url "https://files.pythonhosted.org/packages/a9/ec/0f942e78a621f8e3162ff1ed24284f469aaf51fb4607ee5831c626f2b2bc/langchain-1.3.14-py3-none-any.whl"
    sha256 "4d10dbe91005952cddd56d0dc77aa108964da6bae90ab20063653957e901f782"
  end

  resource "langchain-anthropic" do
    url "https://files.pythonhosted.org/packages/23/d8/47fb549e91f55a54ce829b5034a21360d9383342a3bf4986188e254e89e4/langchain_anthropic-1.5.4-py3-none-any.whl"
    sha256 "730a9cb1ad384c9f1642840469c1ebbf20237066b1635f5d4fa9876e365fceaf"
  end

  resource "langchain-core" do
    url "https://files.pythonhosted.org/packages/36/e6/c7c39efe0bc7e1b7c3d8f54f85846e04c901913c3d3e99068b218558c6f1/langchain_core-1.5.3-py3-none-any.whl"
    sha256 "48b56fa580277209594dd7baf837f5b9a2a3651613f34ff9fb1728b429df015f"
  end

  resource "langchain-google-genai" do
    url "https://files.pythonhosted.org/packages/01/cb/4a2eb187b108a240d57cf8dcf67e818ca75365f769444bf5716e2823cd98/langchain_google_genai-4.3.2-py3-none-any.whl"
    sha256 "f3b1c09b264612fd1735a9590987bfa0cccca0bc0111691543decb5a03b8667d"
  end

  resource "langchain-mcp-adapters" do
    url "https://files.pythonhosted.org/packages/a3/5e/4f117d2500a661079a1895a6eb18954a906e458b1e45fa04a301fcdabd61/langchain_mcp_adapters-0.3.2-py3-none-any.whl"
    sha256 "094e6b3096dbcc408417d5722f6915f164772e50c502ae3d8989405bf12c3c84"
  end

  resource "langchain-openai" do
    url "https://files.pythonhosted.org/packages/f9/3f/58f1dafe9548f976d6dcf9034953106bf19b0adaaa4578fe472ecfce9f38/langchain_openai-1.4.2-py3-none-any.whl"
    sha256 "88208c5bc32dd95d21129a0d6f0ac3f6af380eed46b9fa0944c06c18ea325a49"
  end

  resource "langchain-protocol" do
    url "https://files.pythonhosted.org/packages/99/2e/d82db9eec13ad0f72e7aaad5c4bc730ab111934fdc83c85523206eb9b0a0/langchain_protocol-0.0.18-py3-none-any.whl"
    sha256 "70b53a86fbf9cedc863555effe44da192ab02d556ddbf2cf95b8873adcf41b5a"
  end

  resource "langchain-quickjs" do
    url "https://files.pythonhosted.org/packages/2e/a1/bf460ae2009f76ec2fabd263ad202f6649c6ae6cb7429f0688c4239ff759/langchain_quickjs-0.3.5-py3-none-any.whl"
    sha256 "288b276ea7dcc3cfac2b84b7fed1079ac076e1c682bc3e4e2c2ce31d20ea2d2c"
  end

  resource "langgraph" do
    url "https://files.pythonhosted.org/packages/e2/4d/3fc3e2535ee2c731130d71371848ebc6d4a9d2e8ae6060b11987ba134951/langgraph-1.2.10-py3-none-any.whl"
    sha256 "52c48bd42fa31a1de0e1c0f0ebfe342e11ca2957b8b3563f83dbd60d8e30f921"
  end

  resource "langgraph-api" do
    url "https://files.pythonhosted.org/packages/75/1f/99376a2c96331c8cc368a55e66d5e9000736d5b11913a0b5c606b8c42668/langgraph_api-0.12.0-py3-none-any.whl"
    sha256 "092422be8408f6d3521413697dd213888cf178f4928e54a551d6c9c4d4e78310"
  end

  resource "langgraph-checkpoint" do
    url "https://files.pythonhosted.org/packages/05/71/3b475f09bd57d3a5649792c66353312b4432afd843f301739dfcebd157f0/langgraph_checkpoint-4.2.0-py3-none-any.whl"
    sha256 "0547fd228935a0b758865de3a3d6d7a2537c308895d0f9ab092ce9151b5da942"
  end

  resource "langgraph-checkpoint-sqlite" do
    url "https://files.pythonhosted.org/packages/f5/b9/e458601a1718337839bcfeec9d1b27b8b16ce135be2bd50ed0395d33a878/langgraph_checkpoint_sqlite-3.1.1-py3-none-any.whl"
    sha256 "8505c54c94a658080525d7e6780fdd4e0c078ff2566b30d399c02cc9f9af1c63"
  end

  resource "langgraph-cli" do
    url "https://files.pythonhosted.org/packages/8b/73/afe77f0c81f43b35e41dc90e5bde8c25f6518811258ee5bca1f953e41186/langgraph_cli-0.4.31-py3-none-any.whl"
    sha256 "111da6269d6c9d8606b19264caaa8d5e6b98bb6684233853a5d55489a6e62496"
  end

  resource "langgraph-prebuilt" do
    url "https://files.pythonhosted.org/packages/e9/43/3fe1a700b8490ed02679cdbbc8c915eb23a092faf496c9c1118abcd10be3/langgraph_prebuilt-1.1.0-py3-none-any.whl"
    sha256 "51e311747d755b751d5c6b39b0c1446124d3a7643d2515017e6714b323508fc9"
  end

  resource "langgraph-runtime-inmem" do
    url "https://files.pythonhosted.org/packages/9f/fa/68894d187f4a1fecceb13a5f3865ffa7e3199354d30db0903d549ad728d1/langgraph_runtime_inmem-0.32.1-py3-none-any.whl"
    sha256 "605487951d4bda4945d45d9e79ac48d3ae3ab10549db0f28dcd1a5a277112152"
  end

  resource "langgraph-sdk" do
    url "https://files.pythonhosted.org/packages/a0/05/aac507337cceae773c2cc9ab91eb6301963af7aeeb55b4217a00e15aff17/langgraph_sdk-0.4.2-py3-none-any.whl"
    sha256 "75fa5096c1177ce39c847096a8fe3745ffd480ddb412995f836e9f5f884c43dd"
  end

  resource "langsmith" do
    url "https://files.pythonhosted.org/packages/7d/e6/e264e87ce79467aa0cc6c5e945e74050d7880394da325b3559cfdb41a186/langsmith-0.10.17-py3-none-any.whl"
    sha256 "2a1242a0500147ed846ecbd5fe2f41c21b1652f6833b1af0f209231006f67e5e"
  end

  resource "linkify-it-py" do
    url "https://files.pythonhosted.org/packages/b4/de/88b3be5c31b22333b3ca2f6ff1de4e863d8fe45aaea7485f591970ec1d3e/linkify_it_py-2.1.0-py3-none-any.whl"
    sha256 "0d252c1594ecba2ecedc444053db5d3a9b7ec1b0dd929c8f1d74dce89f86c05e"
  end

  resource "markdown-it-py" do
    url "https://files.pythonhosted.org/packages/b3/81/4da04ced5a082363ecfa159c010d200ecbd959ae410c10c0264a38cac0f5/markdown_it_py-4.2.0-py3-none-any.whl"
    sha256 "9f7ebbcd14fe59494226453aed97c1070d83f8d24b6fc3a3bcf9a38092641c4a"
  end

  resource "markdownify" do
    url "https://files.pythonhosted.org/packages/04/10/fa543d484e8b1199243fe20eedd02cc5af050edebce98a7293a5773df592/markdownify-1.2.3-py3-none-any.whl"
    sha256 "a189a0bedfd14009030fde5f85bb6f77c56897cb839b5c25315dd7d4e3e290ba"
  end

  resource "mcp" do
    url "https://files.pythonhosted.org/packages/01/c8/248b201f6d753d69fd5d6506011abbb35a946d9142b2ae311a948fd0be3d/mcp-1.29.0-py3-none-any.whl"
    sha256 "f5a075bb611f23d6f4d080c6a1699fa62772eebc562ba9e66b306ddde1c755f7"
  end

  resource "mdit-py-plugins" do
    url "https://files.pythonhosted.org/packages/a5/69/6da5581c6a7fede7dc261bf4e67d6adca4196f176b43288b55b3db395b6e/mdit_py_plugins-0.6.1-py3-none-any.whl"
    sha256 "214c82fb2ac524472ab6a5bcab1de80f73b50443e187f401bfd77efbc7c6481d"
  end

  resource "mdurl" do
    url "https://files.pythonhosted.org/packages/b3/38/89ba8ad64ae25be8de66a6d463314cf1eb366222074cfda9ee839c56a4b4/mdurl-0.1.2-py3-none-any.whl"
    sha256 "84008a41e51615a49fc9966191ff91509e3c40b939176e643fd50a5c2196b8f8"
  end

  resource "openai" do
    url "https://files.pythonhosted.org/packages/78/0f/cc6afea3542a5142c5d8fc8211c5e059a8375105d004a41dfa2c7948dbb0/openai-2.53.0-py3-none-any.whl"
    sha256 "c694ffc747a3c4d1663ef2b07b811315a476164ee5efa3a993967349ebca7618"
  end

  resource "opentelemetry-api" do
    url "https://files.pythonhosted.org/packages/91/48/28ed9e55dcf2f453128df738210a980e09f4e468a456fa3c763dbc8be70a/opentelemetry_api-1.37.0-py3-none-any.whl"
    sha256 "accf2024d3e89faec14302213bc39550ec0f4095d1cf5ca688e1bfb1c8612f47"
  end

  resource "opentelemetry-exporter-otlp-proto-common" do
    url "https://files.pythonhosted.org/packages/08/13/b4ef09837409a777f3c0af2a5b4ba9b7af34872bc43609dda0c209e4060d/opentelemetry_exporter_otlp_proto_common-1.37.0-py3-none-any.whl"
    sha256 "53038428449c559b0c564b8d718df3314da387109c4d36bd1b94c9a641b0292e"
  end

  resource "opentelemetry-exporter-otlp-proto-http" do
    url "https://files.pythonhosted.org/packages/e9/e9/70d74a664d83976556cec395d6bfedd9b85ec1498b778367d5f93e373397/opentelemetry_exporter_otlp_proto_http-1.37.0-py3-none-any.whl"
    sha256 "54c42b39945a6cc9d9a2a33decb876eabb9547e0dcb49df090122773447f1aef"
  end

  resource "opentelemetry-exporter-prometheus" do
    url "https://files.pythonhosted.org/packages/a6/e3/50e9cdc5a52c2ab19585dd69e668ec9fee0343fafc4bffa919ca79230a4f/opentelemetry_exporter_prometheus-0.58b0-py3-none-any.whl"
    sha256 "02005033a7a108ab9f3000ff3aa49e2d03a8893b5bf3431322ffa246affbf951"
  end

  resource "opentelemetry-proto" do
    url "https://files.pythonhosted.org/packages/c4/25/f89ea66c59bd7687e218361826c969443c4fa15dfe89733f3bf1e2a9e971/opentelemetry_proto-1.37.0-py3-none-any.whl"
    sha256 "8ed8c066ae8828bbf0c39229979bdf583a126981142378a9cbe9d6fd5701c6e2"
  end

  resource "opentelemetry-sdk" do
    url "https://files.pythonhosted.org/packages/9f/62/9f4ad6a54126fb00f7ed4bb5034964c6e4f00fcd5a905e115bd22707e20d/opentelemetry_sdk-1.37.0-py3-none-any.whl"
    sha256 "8f3c3c22063e52475c5dbced7209495c2c16723d016d39287dfc215d1771257c"
  end

  resource "opentelemetry-semantic-conventions" do
    url "https://files.pythonhosted.org/packages/07/90/68152b7465f50285d3ce2481b3aec2f82822e3f52e5152eeeaf516bab841/opentelemetry_semantic_conventions-0.58b0-py3-none-any.whl"
    sha256 "5564905ab1458b96684db1340232729fce3b5375a06e140e8904c78e4f815b28"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/63/34/ba1c580383c9eada3711951fef0795c80b829a078d72188184bcab9dd527/packaging-26.3-py3-none-any.whl"
    sha256 "d7193f7c8e4e93f444fde0262bf90af30e16fa0ad0ad44cb553c87339b23cd1c"
  end

  resource "pathspec" do
    url "https://files.pythonhosted.org/packages/f1/d9/7fb5aa316bc299258e68c73ba3bddbc499654a07f151cba08f6153988714/pathspec-1.1.1-py3-none-any.whl"
    sha256 "a00ce642f577bf7f473932318056212bc4f8bfdf53128c78bbd5af0b9b20b189"
  end

  resource "platformdirs" do
    url "https://files.pythonhosted.org/packages/4c/85/9b31b44296cfa3bb56cddb35e6a0f6578bab0b490c0806c0245e32c6110c/platformdirs-4.11.1-py3-none-any.whl"
    sha256 "2efd27d363e8dd2e661639ffb398865a5e0a46442a11d266bf375a0e0c10e386"
  end

  resource "prometheus-client" do
    url "https://files.pythonhosted.org/packages/eb/a3/b69efbf4143b5b9859b977770bbbabcc2796b702fa69dc40271e45cd5a56/prometheus_client-0.26.0-py3-none-any.whl"
    sha256 "fa93d06737aa02bacd05794768508bb97d2fbee28cb3bca04eaae92f0ca953d6"
  end

  resource "prompt-toolkit" do
    url "https://files.pythonhosted.org/packages/54/6f/84908cad2d6aa5144abcf7b42709fe4fdb459bc640ec7ac5786e7693dabc/prompt_toolkit-3.0.53-py3-none-any.whl"
    sha256 "01c0891d7f9237d5e339f7d3e42cdae80b7534abb1c7c0e3352efba6231492f2"
  end

  resource "pyasn1" do
    url "https://files.pythonhosted.org/packages/9a/3b/6163796d69c3977d1e4287bea4a6979161cbbdd170ebb430511e8e1999ce/pyasn1-0.6.4-py3-none-any.whl"
    sha256 "deda9277cfd454080ec40b207fb6df82206a3a2688735233cdcd8d3d565f088b"
  end

  resource "pyasn1-modules" do
    url "https://files.pythonhosted.org/packages/47/8d/d529b5d697919ba8c11ad626e835d4039be708a35b0d22de83a269a6682c/pyasn1_modules-0.4.2-py3-none-any.whl"
    sha256 "29253a9207ce32b64c3ac6600edc75368f98473906e8fd1043bd6b5b1de2c14a"
  end

  resource "pycparser" do
    url "https://files.pythonhosted.org/packages/0c/c3/44f3fbbfa403ea2a7c779186dc20772604442dde72947e7d01069cbe98e3/pycparser-3.0-py3-none-any.whl"
    sha256 "b727414169a36b7d524c1c3e31839a521725078d7b2ff038656844266160a992"
  end

  resource "pydantic" do
    url "https://files.pythonhosted.org/packages/fd/7b/122376b1fd3c62c1ed9dc80c931ace4844b3c55407b6fb2d199377c9736f/pydantic-2.13.4-py3-none-any.whl"
    sha256 "45a282cde31d808236fd7ea9d919b128653c8b38b393d1c4ab335c62924d9aba"
  end

  resource "pydantic-settings" do
    url "https://files.pythonhosted.org/packages/30/a4/2bffa9f8e804325a09867f0e9d30795c80ea9f8d62560bd1b6ad6220eb2f/pydantic_settings-2.15.0-py3-none-any.whl"
    sha256 "0ba092c291c94baceb5eff768aa0d56400a457585bc0175925a5a5510303da42"
  end

  resource "pygments" do
    url "https://files.pythonhosted.org/packages/f4/7e/a72dd26f3b0f4f2bf1dd8923c85f7ceb43172af56d63c7383eb62b332364/pygments-2.20.0-py3-none-any.whl"
    sha256 "81a9e26dd42fd28a23a2d169d86d7ac03b46e2f8b59ed4698fb4785f946d0176"
  end

  resource "pyjwt" do
    url "https://files.pythonhosted.org/packages/a3/5e/ecf12fdb62546d64385c158514e9b2b671f7832108ef2ecd2020ce0af2d1/pyjwt-2.13.0-py3-none-any.whl"
    sha256 "66adcc2aff09b3f1bbd95fc1e1577df8ac8723c978552fd43304c8a290ac5728"
  end

  resource "pyperclip" do
    url "https://files.pythonhosted.org/packages/df/80/fc9d01d5ed37ba4c42ca2b55b4339ae6e200b456be3a1aaddf4a9fa99b8c/pyperclip-1.11.0-py3-none-any.whl"
    sha256 "299403e9ff44581cb9ba2ffeed69c7aa96a008622ad0c46cb575ca75b5b84273"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/ec/57/56b9bcc3c9c6a792fcbaf139543cee77261f3651ca9da0c93f5c1221264b/python_dateutil-2.9.0.post0-py2.py3-none-any.whl"
    sha256 "a8b2bc7bffae282281c8140a97d3aa9c14da0b136dfe83f850eea9a5f7470427"
  end

  resource "python-dotenv" do
    url "https://files.pythonhosted.org/packages/0b/d7/1959b9648791274998a9c3526f6d0ec8fd2233e4d4acce81bbae76b44b2a/python_dotenv-1.2.2-py3-none-any.whl"
    sha256 "1d8214789a24de455a8b8bd8ae6fe3c6b69a5e3d64aa8a8e5d68e694bbcb285a"
  end

  resource "python-multipart" do
    url "https://files.pythonhosted.org/packages/e1/04/e8135ebd1ad02c56ec633277529b2602ff99ff634be76cdba5744cf554fd/python_multipart-0.0.32-py3-none-any.whl"
    sha256 "ff6d3f776f16878c894e52e107296ffc890e913c611b1a4ec6c44e2821fe2e23"
  end

  resource "quickjs-rs" do
    url "https://files.pythonhosted.org/packages/d0/1d/e4406d13ce9b9443dbfa59e2a2d5b3e11278ebe322b54de38ae18faf5436/quickjs_rs-0.2.5-py3-none-any.whl"
    sha256 "e82240af1f1dd1b2e12bcf169a22a8e0e451e356f0688f2fc3bba886d9b2bb20"
  end

  resource "referencing" do
    url "https://files.pythonhosted.org/packages/2c/58/ca301544e1fa93ed4f80d724bf5b194f6e4b945841c5bfd555878eea9fcb/referencing-0.37.0-py3-none-any.whl"
    sha256 "381329a9f99628c9069361716891d34ad94af76e461dcb0335825aecc7692231"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/a0/f4/c67b0b3f1b9245e8d266f0f112c500d50e5b4e83cb6f3b71b6528104182a/requests-2.34.2-py3-none-any.whl"
    sha256 "2a0d60c172f83ac6ab31e4554906c0f3b3588d37b5cb939b1c061f4907e278e0"
  end

  resource "requests-toolbelt" do
    url "https://files.pythonhosted.org/packages/3f/51/d4db610ef29373b879047326cbf6fa98b6c1969d6f6dc423279de2b1be2c/requests_toolbelt-1.0.0-py2.py3-none-any.whl"
    sha256 "cccfdd665f0a24fcf4726e690f65639d272bb0637b9b92dfd91a5568ccf6bd06"
  end

  resource "rich" do
    url "https://files.pythonhosted.org/packages/82/3b/64d4899d73f91ba49a8c18a8ff3f0ea8f1c1d75481760df8c68ef5235bf5/rich-15.0.0-py3-none-any.whl"
    sha256 "33bd4ef74232fb73fe9279a257718407f169c09b78a87ad3d296f548e27de0bb"
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/5d/40/e1e72872c6354b306daef1703549e8e83b4d43cfea356311bf722a043752/setuptools-83.0.0-py3-none-any.whl"
    sha256 "29b23c360f22f414dc7336bb39178cc7bcbf6021ed2733cde173f09dba19abb3"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/b7/ce/149a00dd41f10bc29e5921b496af8b574d8413afcd5e30dfa0ed46c2cc5e/six-1.17.0-py2.py3-none-any.whl"
    sha256 "4721f391ed90541fddacab5acf947aa0d3dc7d27b2e1e8eda2be8970586c3274"
  end

  resource "sniffio" do
    url "https://files.pythonhosted.org/packages/e9/44/75a9c9421471a6c4805dbf2356f7c181a29c1879239abab1ea2cc8f38b40/sniffio-1.3.1-py3-none-any.whl"
    sha256 "2f6da418d1f1e0fddd844478f41680e794e6051915791a034ff65e5f100525a2"
  end

  resource "soupsieve" do
    url "https://files.pythonhosted.org/packages/eb/dc/ad025c1ee131eba60c69f4dd5779b18fcf1e6b21a343e2162a84d5d133c7/soupsieve-2.9.2-py3-none-any.whl"
    sha256 "8089a26fd974ca7a1f30276d3d8492ab266ab15af581642dfe8aa162e0c1c823"
  end

  resource "sse-starlette" do
    url "https://files.pythonhosted.org/packages/f8/7f/3de5402f39890ac5660b86bcf5c03f9d855dad5c4ed764866d7b592b46fd/sse_starlette-3.3.4-py3-none-any.whl"
    sha256 "84bb06e58939a8b38d8341f1bc9792f06c2b53f48c608dd207582b664fc8f3c1"
  end

  resource "starlette" do
    url "https://files.pythonhosted.org/packages/75/0a/67e95f21498de41433babf7b1db0eeab449eb58872dfb831b27747a70fd0/starlette-1.4.1-py3-none-any.whl"
    sha256 "7d078e0fbefae0d2cecfb80a799d6fb84b1c0c6acd4f14ac79d17d0e7ec27f19"
  end

  resource "structlog" do
    url "https://files.pythonhosted.org/packages/a8/45/a132b9074aa18e799b891b91ad72133c98d8042c70f6240e4c5f9dabee2f/structlog-25.5.0-py3-none-any.whl"
    sha256 "a8453e9b9e636ec59bd9e79bbd4a72f025981b3ba0f5837aebf48f02f37a7f9f"
  end

  resource "tavily-python" do
    url "https://files.pythonhosted.org/packages/67/dd/cf4b6668ef06670a27ed4012f2bd3663602ad5f0e1ac9b0c23e8d45d01eb/tavily_python-0.7.27-py3-none-any.whl"
    sha256 "e5cb40cc852d108ced8a313379b7098108642eedfbd97f821296a5e1a483e9b9"
  end

  resource "tenacity" do
    url "https://files.pythonhosted.org/packages/d7/c1/eb8f9debc45d3b7918a32ab756658a0904732f75e555402972246b0b8e71/tenacity-9.1.4-py3-none-any.whl"
    sha256 "6095a360c919085f28c6527de529e76a06ad89b23659fa881ae0649b867a9d55"
  end

  resource "textual" do
    url "https://files.pythonhosted.org/packages/fb/be/35261223d9416a0751cdff1c7b4a6f881387218a12d439fe22fefebc8c04/textual-8.2.8-py3-none-any.whl"
    sha256 "267375fd402dc8d981457212efa71f0e3365fd17bba144ba9bb3ed7563cb374a"
  end

  resource "textual-autocomplete" do
    url "https://files.pythonhosted.org/packages/9f/66/ebe744d79c87f25a42d2654dddbd09462edd595f2ded715245a51a546461/textual_autocomplete-4.0.6-py3-none-any.whl"
    sha256 "bff69c19386e2cbb4a007503b058dc37671d480a4fa2ddb3959c15ceb4aff9b5"
  end

  resource "tomli-w" do
    url "https://files.pythonhosted.org/packages/c7/18/c86eb8e0202e32dd3df50d43d7ff9854f8e0603945ff398974c1d91ac1ef/tomli_w-1.2.0-py3-none-any.whl"
    sha256 "188306098d013b691fcadc011abd66727d3c414c571bb01b1a174ba8c983cf90"
  end

  resource "tqdm" do
    url "https://files.pythonhosted.org/packages/f9/1c/01bfd571a64e7f270e6bab5e33777debe0edc56759233ce84f27dec92d14/tqdm-4.70.0-py3-none-any.whl"
    sha256 "7f585706bfddbdebf89daac705b2dfcc16890130727d3197ca62c732b4310953"
  end

  resource "truststore" do
    url "https://files.pythonhosted.org/packages/19/97/56608b2249fe206a67cd573bc93cd9896e1efb9e98bce9c163bcdc704b88/truststore-0.10.4-py3-none-any.whl"
    sha256 "adaeaecf1cbb5f4de3b1959b42d41f6fab57b2b1666adb59e89cb0b53361d981"
  end

  resource "typing-extensions" do
    url "https://files.pythonhosted.org/packages/49/d3/b8441a820a491ddfc024b0b0cf0393375b75ea13866d9c66727e54c2fc80/typing_extensions-4.16.0-py3-none-any.whl"
    sha256 "481caa481374e813c1b176ada14e97f1f67a4539ce9cfeb3f350d78d6370c2e8"
  end

  resource "typing-inspection" do
    url "https://files.pythonhosted.org/packages/dc/9b/47798a6c91d8bdb567fe2698fe81e0c6b7cb7ef4d13da4114b41d239f65d/typing_inspection-0.4.2-py3-none-any.whl"
    sha256 "4ed1cacbdc298c220f1bd249ed5287caa16f34d44ef4e9c3d0cbad5b521545e7"
  end

  resource "uc-micro-py" do
    url "https://files.pythonhosted.org/packages/61/73/d21edf5b204d1467e06500080a50f79d49ef2b997c79123a536d4a17d97c/uc_micro_py-2.0.0-py3-none-any.whl"
    sha256 "3603a3859af53e5a39bc7677713c78ea6589ff188d70f4fee165db88e22b242c"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/7f/3e/5db95bcf282c52709639744ca2a8b149baccf648e39c8cc87553df9eae0c/urllib3-2.7.0-py3-none-any.whl"
    sha256 "9fb4c81ebbb1ce9531cce37674bbc6f1360472bc18ca9a553ede278ef7276897"
  end

  resource "uvicorn" do
    url "https://files.pythonhosted.org/packages/c7/d5/68e6e9bca63c0badf67002890a46d3784c958de45b65e1275ec583ca1f06/uvicorn-0.52.1-py3-none-any.whl"
    sha256 "e4403f9d93188cf9d1088e9f40e3acd12630e2df8675316704379a7fc20fff6a"
  end

  resource "wcmatch" do
    url "https://files.pythonhosted.org/packages/28/12/f38b6fee116274d7221743caab07d765032e1370bb54cad8714f87aeb0e8/wcmatch-11.0-py3-none-any.whl"
    sha256 "3a5977ace27e075eef67eb03d539563f1a19018b62881949a42932cf66926934"
  end

  resource "wcwidth" do
    url "https://files.pythonhosted.org/packages/96/42/3e5985a0a7e57de470b320c6d6a1a67c844f6737a587f3d44dd13d1819e7/wcwidth-0.8.2-py3-none-any.whl"
    sha256 "d63947694a0539a1d51e01eda7caf800c291020e6cdd7e28ad7b14dd33ad4f85"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/87/1b/9e33c09813d65e248f7f773119148a612516a4bea93e9c6f545f78455b7c/wheel-0.47.0-py3-none-any.whl"
    sha256 "212281cab4dff978f6cedd499cd893e1f620791ca6ff7107cf270781e587eced"
  end

  resource "zipp" do
    url "https://files.pythonhosted.org/packages/3a/13/547360d81e6d88d58492968ffda9f9542854f11310ee556fef14260cc886/zipp-4.1.0-py3-none-any.whl"
    sha256 "25ad4e16390cd314347dd8f1de67a2ac538ae658ed4ab9db16029c07c188e97f"
  end

  # No wheel on PyPI; the pure-Python sdist is built offline at install time
  # (the bundled setuptools/wheel build backend make this work without network).
  resource "forbiddenfruit" do
    url "https://files.pythonhosted.org/packages/e6/79/d4f20e91327c98096d605646bdc6a5ffedae820f38d378d3515c42ec5e60/forbiddenfruit-0.1.4.tar.gz"
    sha256 "e3f7e66561a29ae129aac139a85d610dbf3dd896128187ed5454b6421f624253"
  end

  def install
    # Create the virtualenv via the mixin (its Cellar->opt symlink-hardening lets
    # the venv survive python@3.13 patch upgrades), then install prebuilt
    # wheels with uv - fully offline, no network, no compilation.
    virtualenv_create(libexec, "python3.13")

    # Assemble an offline wheelhouse from the downloaded artifacts. Copy each
    # cached download under its real filename (wheels stay wheels, sdists stay
    # tarballs) so uv can resolve everything locally with no network.
    wheelhouse = buildpath/"wheelhouse"
    wheelhouse.mkpath
    cp Dir[buildpath/"*.whl"], wheelhouse # main package wheel (downloaded :nounzip)
    resources.each { |r| cp r.cached_download, wheelhouse/File.basename(r.url) }

    system "uv", "pip", "install", "--python", libexec/"bin/python",
           "--offline", "--no-index", "--find-links=#{wheelhouse}",
           "deepagents-code==#{version}"

    bin.install_symlink libexec/"bin/dcode", libexec/"bin/deepagents-code"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dcode --version")
    assert_match version.to_s, shell_output("#{bin}/deepagents-code --version")
  end
end
