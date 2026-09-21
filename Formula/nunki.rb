class Nunki < Formula
  desc "Architecture docs from source code, verified against the commit"
  homepage "https://github.com/sadaramk/nunki"
  version "0.4.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/sadaramk/nunki/releases/download/v0.4.1/nunki-0.4.1-aarch64-apple-darwin.tar.gz"
      sha256 "815698642e5b4311d5a4d3cced1ce413029aa112ce371e73bd5326dc1118ec6c"
    end
    on_intel do
      url "https://github.com/sadaramk/nunki/releases/download/v0.4.1/nunki-0.4.1-x86_64-apple-darwin.tar.gz"
      sha256 "a4cd43ea6fd21398008c029b83927f7ad920d405b4ad80a0691b39bf8649d66c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/sadaramk/nunki/releases/download/v0.4.1/nunki-0.4.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "11f03e89c279b86f0a933c9a3943bb05d197395dcacbe4627b1613104d3c15e0"
    end
    on_intel do
      url "https://github.com/sadaramk/nunki/releases/download/v0.4.1/nunki-0.4.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "3e4d93634d97bf3c6524fc570ede5039aa2c8d916b9f78dc3267d35b48a88bfb"
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
