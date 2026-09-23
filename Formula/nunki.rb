class Nunki < Formula
  desc "Architecture docs from source code, verified against the commit"
  homepage "https://github.com/sadaramk/nunki"
  version "0.5.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/sadaramk/nunki/releases/download/v0.5.0/nunki-0.5.0-aarch64-apple-darwin.tar.gz"
      sha256 "4a375a0eb3e45ce4f366047388aeded72c5c11312822d52faa9588a8746049df"
    end
    on_intel do
      url "https://github.com/sadaramk/nunki/releases/download/v0.5.0/nunki-0.5.0-x86_64-apple-darwin.tar.gz"
      sha256 "70ad6f2349ff5ffa3f38e2b4c6cbc30b65ab789df27b02fd90bf9552b3f1f0d3"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/sadaramk/nunki/releases/download/v0.5.0/nunki-0.5.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "b7de04e91895ea987a29f6b9826779c1daaca82d2fb0f29bafd937ce6d81bde5"
    end
    on_intel do
      url "https://github.com/sadaramk/nunki/releases/download/v0.5.0/nunki-0.5.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "c46af29bae036d7147336006dcdd35d1afcc26b8c247278a3f0d8ccea3abc28c"
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
