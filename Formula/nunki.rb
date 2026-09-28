class Nunki < Formula
  desc "Architecture docs from source code, verified against the commit"
  homepage "https://github.com/sadaramk/nunki"
  version "0.6.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/sadaramk/nunki/releases/download/v0.6.0/nunki-0.6.0-aarch64-apple-darwin.tar.gz"
      sha256 "2ca532cf6f238ff9429194301682ef9dcd4cfb9ca37bfd821a3ddddc8498365a"
    end
    on_intel do
      url "https://github.com/sadaramk/nunki/releases/download/v0.6.0/nunki-0.6.0-x86_64-apple-darwin.tar.gz"
      sha256 "7c78ccf2af74a4bab5de5dd93818d2572e02ccbf86301578feeb0d31651e3a5d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/sadaramk/nunki/releases/download/v0.6.0/nunki-0.6.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "92d45e90aaa12286bd0983783e8f475da77264f39861dd6db870e357e0138d1f"
    end
    on_intel do
      url "https://github.com/sadaramk/nunki/releases/download/v0.6.0/nunki-0.6.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "e53459a9cd389fcf44b444ba44473bbfa12c147522468f958ccb33d2a238d293"
    end
  end

  def install
    bin.install "nunki"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/nunki --version")

    # A real repository, documented end to end: the point of the tool is that
    # the book it writes cites code and that `check` can verify those citations
    # afterwards. A `--version` smoke test would not catch a binary that runs
    # but cannot read a tree.
    (testpath/"svc/main.go").write <<~GO
      package main

      import "net/http"

      func main() {
      \tmux := http.NewServeMux()
      \tmux.HandleFunc("GET /widgets", list)
      \thttp.ListenAndServe(":8080", mux)
      }

      func list(w http.ResponseWriter, r *http.Request) {}
    GO
    (testpath/"svc/go.mod").write "module example.com/svc\n\ngo 1.22\n"

    system "git", "-C", testpath, "init", "-q"
    system "git", "-C", testpath, "-c", "user.email=t@example.com",
           "-c", "user.name=t", "add", "."
    system "git", "-C", testpath, "-c", "user.email=t@example.com",
           "-c", "user.name=t", "commit", "-qm", "init"

    system bin/"nunki", "generate", testpath, "--out", testpath/"book"
    assert_path_exists testpath/"book/index.html"
    system bin/"nunki", "check", testpath, "--out", testpath/"book"
  end
end
