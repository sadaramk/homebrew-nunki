class Nunki < Formula
  desc "Architecture docs from source code, verified against the commit"
  homepage "https://github.com/sadaramk/nunki"
  version "0.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/sadaramk/nunki/releases/download/v0.3.0/nunki-0.3.0-aarch64-apple-darwin.tar.gz"
      sha256 "b33f72e569e3d821f1e8f17f01a73e5ef80e711f7e000b627353ecb1f7949e7e"
    end
    on_intel do
      url "https://github.com/sadaramk/nunki/releases/download/v0.3.0/nunki-0.3.0-x86_64-apple-darwin.tar.gz"
      sha256 "a6f15d82808cca08e6676ae33ba6ed7c6784a907feab7dacbd540e1019d0472d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/sadaramk/nunki/releases/download/v0.3.0/nunki-0.3.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "85f5c719da0ab11ae929bc5862272fd5c5d146785d7dce73f0368ab9f27b2a90"
    end
    on_intel do
      url "https://github.com/sadaramk/nunki/releases/download/v0.3.0/nunki-0.3.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "391c98766e6e22fd9716b2af65bfb40a7c500bc0d1564ec9aafb9d860787f02e"
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
