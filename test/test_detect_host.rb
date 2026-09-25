require File.expand_path('../helper', __FILE__)
require 'tmpdir'

class TestDetectHost < TestCase
  def setup
    super
    @tmpdir = Dir.mktmpdir
    @fake_cc = File.join(@tmpdir, "fake_cc.rb")
    File.write(@fake_cc, <<~RUBY)
      puts "clang version 19.1.7"
      puts "Target: \#{ENV.fetch("FAKE_CC_TARGET")}"
      puts "Thread model: posix"
    RUBY
    @old_cc = ENV.delete("CC")
  end

  def teardown
    ENV["CC"] = @old_cc if @old_cc
    ENV.delete("FAKE_CC_TARGET")
    FileUtils.rm_rf(@tmpdir)
    super
  end

  def detected_host_for(target)
    ENV["FAKE_CC_TARGET"] = target
    MiniPortile.new("libfoo", "1.0.0", cc_command: "\"#{RbConfig.ruby}\" \"#{@fake_cc}\"").host
  end

  def test_gnu_triples_are_unchanged
    assert_equal("x86_64-w64-mingw32", detected_host_for("x86_64-w64-mingw32"))
    assert_equal("aarch64-w64-mingw32", detected_host_for("aarch64-w64-mingw32"))
    assert_equal("x86_64-pc-linux-gnu", detected_host_for("x86_64-pc-linux-gnu"))
    assert_equal("arm64-apple-darwin24.0.0", detected_host_for("arm64-apple-darwin24.0.0"))
  end

  def test_llvm_windows_gnu_triples_are_translated_to_mingw32
    assert_equal("aarch64-w64-mingw32", detected_host_for("aarch64-w64-windows-gnu"))
    assert_equal("x86_64-w64-mingw32", detected_host_for("x86_64-w64-windows-gnu"))
    assert_equal("x86_64-w64-mingw32", detected_host_for("x86_64-pc-windows-gnu"))
    assert_equal("i686-w64-mingw32", detected_host_for("i686-windows-gnu"))
  end

  def test_windows_msvc_triples_are_unchanged
    assert_equal("x86_64-pc-windows-msvc", detected_host_for("x86_64-pc-windows-msvc"))
  end
end
