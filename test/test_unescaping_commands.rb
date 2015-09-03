require File.expand_path('../helper', __FILE__)
require 'mini_portile'

class TestUnescapingCommands < TestCase
  class << self
    def startup
      FileUtils.rm_rf "tmp" # remove any previous test files
    end
  end

  def echo_helper recipe, string
    FileUtils.mkdir_p File.join(recipe.send(:tmp_path), "workdir")
    recipe.send :execute, "echo", ["/usr/bin/env", "echo", "-en", string]
    File.read Dir.glob("tmp/**/echo.log").first
  end

  def test_setting_unescape_to_true_unescapes_escaped_strings
    recipe = MiniPortile.new("foo", "1.0", :unescape_commands => true)
    assert_equal "thistthat", echo_helper(recipe, 'this\tthat')
  end

  def test_setting_unescape_to_false_does_not_touch_unescaped_strings
    recipe = MiniPortile.new("foo", "1.0", :unescape_commands => false)
    assert_equal "this\tthat", echo_helper(recipe, 'this\tthat')
  end

  def test_default_unescape_setting_is_true
    recipe = MiniPortile.new("foo", "1.0")
    assert_true recipe.unescape_commands
  end
end
