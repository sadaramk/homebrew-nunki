class Nunki < Formula
  desc "Architecture docs from source code, verified against the commit"
  homepage "https://github.com/sadaramk/nunki"
  version "0.4.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/sadaramk/nunki/releases/download/v0.4.0/nunki-0.4.0-aarch64-apple-darwin.tar.gz"
      sha256 "8e6a2ea365ca1e5b9c42a096d69dd1c7a16044f56a61d15c86b58e890997e433"
    end
    on_intel do
      url "https://github.com/sadaramk/nunki/releases/download/v0.4.0/nunki-0.4.0-x86_64-apple-darwin.tar.gz"
      sha256 "092e1baa8c57a1aa3889843fd3daf7ae4bf6cd3a6e1a84d84535c04a02ca40fc"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/sadaramk/nunki/releases/download/v0.4.0/nunki-0.4.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "d7583ab276eb46f9435ec800bdf44d3f06d573c3bdd1c86e62b3b070f7ebffc8"
    end
    on_intel do
      url "https://github.com/sadaramk/nunki/releases/download/v0.4.0/nunki-0.4.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "e0d9ed6e9de3efa45423300589670d97b07b67c6f0852a14fb7f05c4addc51e6"
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
