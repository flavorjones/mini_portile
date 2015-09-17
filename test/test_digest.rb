require File.expand_path('../helper', __FILE__)

class TestDigest < TestCase
  attr :assets_path, :tar_path, :recipe

  def before_all
    super
    @assets_path = File.expand_path("../assets", __FILE__)
    @tar_path = File.expand_path("../../tmp/test-digest-1.0.0.tar.gz", __FILE__)

    # remove any previous test files
    FileUtils.rm_rf("tmp")

    create_tar(@tar_path, @assets_path, "test mini portile-1.0.0")
    start_webrick(File.dirname(@tar_path))
  end

  def after_all
    super
    stop_webrick
    # leave test files for inspection
  end

  def setup
    super
    FileUtils.rm_rf("ports/archives")
    @recipe = MiniPortile.new("test-digest", "1.0.0")
  end

  def download_with_digest(key, klass)
    @recipe.files << {
      :url => "http://localhost:#{webrick.config[:Port]}/#{ERB::Util.url_encode(File.basename(tar_path))}",
      key => klass.file(tar_path).hexdigest,
    }
    @recipe.download
  end

  def download_with_wrong_digest(key)
    @recipe.files << {
      :url => "http://localhost:#{webrick.config[:Port]}/#{ERB::Util.url_encode(File.basename(tar_path))}",
      key => "0011223344556677",
    }
    assert_raises(RuntimeError){ @recipe.download }
  end

  def test_sha256
    download_with_digest(:sha256, Digest::SHA256)
  end

  def test_wrong_sha256
    download_with_wrong_digest(:sha256)
  end

  def test_sha1
    download_with_digest(:sha1, Digest::SHA1)
  end

  def test_wrong_sha1
    download_with_wrong_digest(:sha1)
  end

  def test_md5
    download_with_digest(:md5, Digest::MD5)
  end

  def test_wrong_md5
    download_with_wrong_digest(:md5)
  end

  def test_with_valid_gpg_signature
    key       = "A1C052F8"
    signature = <<-SIGNATURE
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJV002uAAoJEFIKmZOhwFL41AcH/2VX1/5mD3dAUXfDaYMG92IV
aA8vHlsvXpCEPfCYBnPGYYFa/P0qPyw6hsWXZhWEGEm+BqZK6dWCLFaxTVTtsjOE
vhSR+LL+FNxYmGbK2lYq61PDDL45x5Qnhy3WK1e40F7CqmElSfMOjLuCNC7xR9Jc
zAZ014ADQ5yfH+Ma40K997AxZeCVGU+A5IEHGoZ2i8pyqx0Jhh6cbpC18yHu5ciN
0o4E4cLSFFckYB3FnUpDowRonBDNUpDRJVKMo5cvvskc/GWVUVomPuWyNGFPPmMJ
aySUQcOvO67Z14d9E9ziX/E24KWl6xRymmy9VhzawgSmf//3yZVaD6C/8om3qMw=
=zjw3
-----END PGP SIGNATURE-----
    SIGNATURE

    @recipe.files << {
      :url => "http://nginx.org/download/nginx-1.9.4.tar.gz",
      :gpg => {
        :key => key,
        :signature => signature
      }
    }
    @recipe.download
  end

  def test_with_invalid_gpg_signature
    key       = "A1C052F8"
    signature = <<-SIGNATURE
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJV002uAAoJEFIKmZOhwFL41AcH/2VX1/5mD3dAUXfDaYMG92IV
AA8vHlsvXpCEPfCYBnPGYYFa/P0qPyw6hsWXZhWEGEm+BqZK6dWCLFaxTVTtsjOE
vhSR+LL+FNxYmGbK2lYq61PDDL45x5Qnhy3WK1e40F7CqmElSfMOjLuCNC7xR9Jc
zAZ014ADQ5yfH+Ma40K997AxZeCVGU+A5IEHGoZ2i8pyqx0Jhh6cbpC18yHu5ciN
0o4E4cLSFFckYB3FnUpDowRonBDNUpDRJVKMo5cvvskc/GWVUVomPuWyNGFPPmMJ
aySUQcOvO67Z14d9E9ziX/E24KWl6xRymmy9VhzawgSmf//3yZVaD6C/8om3qMw=
=zjw3
-----END PGP SIGNATURE-----
    SIGNATURE

    @recipe.files << {
      :url => "http://nginx.org/download/nginx-1.9.4.tar.gz",
      :gpg => {
        :key => key,
        :signature => signature
      }
    }
    exception = assert_raise(RuntimeError){ @recipe.download }
    assert_equal("signature mismatch", exception.message)
  end

  def test_with_invalid_key
    key       = "thisisaninvalidkey"
    signature = <<-SIGNATURE
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJV002uAAoJEFIKmZOhwFL41AcH/2VX1/5mD3dAUXfDaYMG92IV
aA8vHlsvXpCEPfCYBnPGYYFa/P0qPyw6hsWXZhWEGEm+BqZK6dWCLFaxTVTtsjOE
vhSR+LL+FNxYmGbK2lYq61PDDL45x5Qnhy3WK1e40F7CqmElSfMOjLuCNC7xR9Jc
zAZ014ADQ5yfH+Ma40K997AxZeCVGU+A5IEHGoZ2i8pyqx0Jhh6cbpC18yHu5ciN
0o4E4cLSFFckYB3FnUpDowRonBDNUpDRJVKMo5cvvskc/GWVUVomPuWyNGFPPmMJ
aySUQcOvO67Z14d9E9ziX/E24KWl6xRymmy9VhzawgSmf//3yZVaD6C/8om3qMw=
=zjw3
-----END PGP SIGNATURE-----
    SIGNATURE

    @recipe.files << {
      :url => "http://nginx.org/download/nginx-1.9.4.tar.gz",
      :gpg => {
        :key => key,
        :signature => signature
      }
    }
    exception = assert_raise(RuntimeError){ @recipe.download }
    assert_equal("key download failed", exception.message)
  end
end

