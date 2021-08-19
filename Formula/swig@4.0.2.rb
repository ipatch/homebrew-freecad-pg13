class SwigAT402 < Formula
  desc "Generate scripting interfaces to C/C++ code"
  homepage "http://www.swig.org/"
  url "https://downloads.sourceforge.net/project/swig/swig/swig-4.0.2/swig-4.0.2.tar.gz"
  sha256 "d53be9730d8d58a16bf0cbd1f8ac0c0c3e1090573168bfa151b01eb47fa906fc"
  # NOTE: see my github issue, config script does not have +x bit, siwg.exp1 branch
  # url "https://github.com/swig/swig/archive/refs/tags/v4.0.2.tar.gz"
  # sha256 "b5f43d5f94c57ede694ffe5e805acc5a3a412387d7f97dcf290d06c46335cb0b"
  license "GPL-3.0"

  livecheck do
    url :stable
  end

  bottle do
    root_url "https://github.com/ipatch/homebrew-freecad-pg13/releases/download/swig@4.0.2-4.0.2"
    rebuild 5
    sha256 big_sur:  "664546034ddeb015c188b24564ec307feb80c0f2a802c605776d9eff422f6745"
    sha256 catalina: "4cfe95a403dbda36c956d3435424b179be1facadaee9574e18e31c63bc0ae824"
    sha256 mojave:   "c003ba0b7e714096022c471c823b98390a200cebeea0c8ac2354a46c6aef1fe1"
  end

  head do
    url "https://github.com/swig/swig.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  # foo
  # bar
  depends_on "pcre"

  uses_from_macos "ruby" => :test

  def install
    # system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      int add(int x, int y)
      {
        return x + y;
      }
    EOS
    (testpath/"test.i").write <<~EOS
      %module test
      %inline %{
      extern int add(int x, int y);
      %}
    EOS
    (testpath/"run.rb").write <<~EOS
      require "./test"
      puts Test.add(1, 1)
    EOS
    system "#{bin}/swig", "-ruby", "test.i"
    system ENV.cc, "-c", "test.c"
    system ENV.cc, "-c", "test_wrap.c", "-I#{MacOS.sdk_path}/System/Library/Frameworks/Ruby.framework/Headers/"
    system ENV.cc, "-bundle", "-undefined", "dynamic_lookup", "test.o", "test_wrap.o", "-o", "test.bundle"
    assert_equal "2", shell_output("/usr/bin/ruby run.rb").strip
  end
end
