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
    rebuild 6
    sha256 big_sur:  "0463075edc892584b943e206c46ceb5c48bfa618e70ff8be75d1d20e276551fc"
    sha256 catalina: "b3a2ea002342e96f2fdf7b3a3db66460de617715b0fab8d73abd24c287e14a96"
    sha256 mojave:   "027ce2034f9a8f1f774d2f321c155f8f089365c58512ea98a71bdb9e6d3449ad"
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
