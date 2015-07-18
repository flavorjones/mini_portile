require File.expand_path('../helper', __FILE__)
require 'fileutils'
require 'socket'
require 'mini_portile'

class TestProxy < TestCase
  def with_dummy_proxy
    gs = TCPServer.open('localhost', 0)
    th = Thread.new do
      s = gs.accept
      gs.close
      begin
        s.gets
      ensure
        s.close
      end
    end

    yield "http://localhost:#{gs.addr[1]}"

    # Set timeout for reception of the request
    Thread.new do
      sleep 1
      th.kill
    end
    th.value
  end

  def setup
    # remove any download files
    FileUtils.rm_rf("port/archives")
  end

  def test_http_proxy
    recipe = MiniPortile.new("test http_proxy", "1.0.0")
    recipe.files << "http://myserver/path/to/tar.gz"
    request = with_dummy_proxy do |url, thread|
      ENV['http_proxy'] = url
      assert_raise(RuntimeError) { recipe.cook }
      ENV.delete('http_proxy')
    end
    assert_match(/GET http:\/\/myserver\/path\/to\/tar.gz/, request)
  end

  def test_https_proxy
    recipe = MiniPortile.new("test https_proxy", "1.0.0")
    recipe.files << "https://myserver/path/to/tar.gz"
    request = with_dummy_proxy do |url, thread|
      ENV['https_proxy'] = url
      assert_raise(RuntimeError) { recipe.cook }
      ENV.delete('https_proxy')
    end
    assert_match(/CONNECT myserver:443/, request)
  end

  def test_ftp_proxy
    recipe = MiniPortile.new("test ftp_proxy", "1.0.0")
    recipe.files << "ftp://myserver/path/to/tar.gz"
    request = with_dummy_proxy do |url, thread|
      ENV['ftp_proxy'] = url
      assert_raise(RuntimeError) { recipe.cook }
      ENV.delete('ftp_proxy')
    end
    assert_match(/GET ftp:\/\/myserver\/path\/to\/tar.gz/, request)
  end
end
