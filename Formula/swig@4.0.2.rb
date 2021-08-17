class SwigAT402 < Formula
  desc "Generate scripting interfaces to C/C++ code"
  homepage "http://www.swig.org/"
  url "https://downloads.sourceforge.net/project/swig/swig/swig-4.0.2/swig-4.0.2.tar.gz"
  sha256 "d53be9730d8d58a16bf0cbd1f8ac0c0c3e1090573168bfa151b01eb47fa906fc"
  # NOTE: see my github issue, config script does not have +x bit set foo
  # url "https://github.com/swig/swig/archive/refs/tags/v4.0.2.tar.gz"
  # sha256 "b5f43d5f94c57ede694ffe5e805acc5a3a412387d7f97dcf290d06c46335cb0b"
  license "GPL-3.0"

  livecheck do
    url :stable
  end

  bottle do
    root_url "https://github.com/ipatch/homebrew-freecad-pg13/releases/download/swig@4.0.2-4.0.2"
    rebuild 4
    sha256 catalina: "70b78256c8c73be7b805dd13d40a171e16d29b3476ee1442c970db3d9dde2788"
    sha256 mojave:   "877b3674c1eed048cf0b3bdd87d2daa947d8d56ca9cdbc464433bf8079993083"
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
