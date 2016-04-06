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
    key       = <<-KEY
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mI0EVwUhJQEEAMYxFhgaAdM2Ul5r+XfpqAaI7SOxB14eRjhFjhchy4ylgVxetyLq
di3zeANXBIHsLBl7quYTlnmhJr/+GQRkCnXWiUp0tJsBVzGM3puK7c534gakEUH6
AlDtj5p3IeygzSyn8u7KORv+ainXfhwkvTO04mJmxAb2uT8ngKYFdPa1ABEBAAG0
J1Rlc3QgTWluaXBvcnRpbGUgPHRlc3RAbWluaXBvcnRpbGUub3JnPoi4BBMBAgAi
BQJXBSElAhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRBl6D5JZMNwswAK
A/90Cdb+PX21weBR2Q6uR06M/alPexuXXyJL8ZcwbQMJ/pBBgcS5/h1+rQkBI/CN
qpXdDlw2Xys2k0sNwdjIw3hmYRzBrddXlCSW3Sifq/hS+kfPZ1snQmIjCgy1Xky5
QGCcPUxBUxzmra88LakkDO+euKK3hcrfeFIi611lTum1NLiNBFcFISUBBADoyY6z
2PwH3RWUbqv0VX1s3/JO3v3xMjCRKPlFwsNwLTBtZoWfR6Ao1ajeCuZKfzNKIQ2I
rn86Rcqyrq4hTj+7BTWjkIPOBthjiL1YqbEBtX7jcYRkYvdQz/IG2F4zVV6X4AAR
Twx7qaXNt67ArzbHCe5gLNRUK6e6OArkahMv7QARAQABiJ8EGAECAAkFAlcFISUC
GwwACgkQZeg+SWTDcLNFiwP/TR33ClqWOz0mpjt0xPEoZ0ORmV6fo4sjjzgQoHH/
KTdsabJbGp8oLQGW/mx3OxgbsAkyZymb5H5cjaF4HtSd4cxI5t1C9ZS/ytN8pqfR
e29SBje8DAAJn2l57s2OddXLPQ0DUwCcdNEaqgHwSk/Swxc7K+IpfvjLKHKUZZBP
4Ko=
=SVWi
-----END PGP PUBLIC KEY BLOCK-----
KEY
    signature = <<-SIGNATURE
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iJwEAAECAAYFAlcFOD8ACgkQZeg+SWTDcLNIswP/XvVRoJ+eQ2u2v+WjXdBBKBSW
pzM216aJPRBxPl98xNUUKjqga+tjKmIHJn5T4CIxHqis1toPxtE5tKnc6cVO1aqY
bCUfkWyt/A3qRHQuniRUWSBKZWdk+j3AopTpd3i/r/s0pDj3bMHJ7bDOTsEskNcM
KpgFfNM1ieFRQmIWPWg=
=kbKc
-----END PGP SIGNATURE-----
    SIGNATURE

    data_file = File.expand_path(File.join(File.dirname(__FILE__), 'assets', 'gpg-fixtures', 'data'))

    @recipe.files << {
      :url => "file://#{data_file}",
      :gpg => {
        :key => key,
        :signature => signature
      }
    }
    @recipe.download
  end

  def test_with_invalid_gpg_signature
    key       = <<-KEY
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mI0EVwUhJQEEAMYxFhgaAdM2Ul5r+XfpqAaI7SOxB14eRjhFjhchy4ylgVxetyLq
di3zeANXBIHsLBl7quYTlnmhJr/+GQRkCnXWiUp0tJsBVzGM3puK7c534gakEUH6
AlDtj5p3IeygzSyn8u7KORv+ainXfhwkvTO04mJmxAb2uT8ngKYFdPa1ABEBAAG0
J1Rlc3QgTWluaXBvcnRpbGUgPHRlc3RAbWluaXBvcnRpbGUub3JnPoi4BBMBAgAi
BQJXBSElAhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRBl6D5JZMNwswAK
A/90Cdb+PX21weBR2Q6uR06M/alPexuXXyJL8ZcwbQMJ/pBBgcS5/h1+rQkBI/CN
qpXdDlw2Xys2k0sNwdjIw3hmYRzBrddXlCSW3Sifq/hS+kfPZ1snQmIjCgy1Xky5
QGCcPUxBUxzmra88LakkDO+euKK3hcrfeFIi611lTum1NLiNBFcFISUBBADoyY6z
2PwH3RWUbqv0VX1s3/JO3v3xMjCRKPlFwsNwLTBtZoWfR6Ao1ajeCuZKfzNKIQ2I
rn86Rcqyrq4hTj+7BTWjkIPOBthjiL1YqbEBtX7jcYRkYvdQz/IG2F4zVV6X4AAR
Twx7qaXNt67ArzbHCe5gLNRUK6e6OArkahMv7QARAQABiJ8EGAECAAkFAlcFISUC
GwwACgkQZeg+SWTDcLNFiwP/TR33ClqWOz0mpjt0xPEoZ0ORmV6fo4sjjzgQoHH/
KTdsabJbGp8oLQGW/mx3OxgbsAkyZymb5H5cjaF4HtSd4cxI5t1C9ZS/ytN8pqfR
e29SBje8DAAJn2l57s2OddXLPQ0DUwCcdNEaqgHwSk/Swxc7K+IpfvjLKHKUZZBP
4Ko=
=SVWi
-----END PGP PUBLIC KEY BLOCK-----
KEY
    signature = <<-SIGNATURE
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iJwEAQECAAYFAlcFLEgACgkQZeg+SWTDcLPVwgQAg8KTI91Ryx38YplzgWV9tUPj
o7J7IEzb8faE7m2mgtq8m62DvA4h/PJzmbh1EJJ4VkO+A4O2LVh/bTgnyYXv+kMu
sEmvK35PnAC8r7pv98VSbMEXyV/rK3+uGhTvnXZYkULvMVYkN/EHIh2bCQJ3R14X
MY8El95QST8/dR/yBkw=
=qbod
-----END PGP SIGNATURE-----
    SIGNATURE

    data_file = File.expand_path(File.join(File.dirname(__FILE__), 'assets', 'gpg-fixtures', 'data'))

    @recipe.files << {
      :url => "file://#{data_file}",
      :gpg => {
        :key => key,
        :signature => signature
      }
    }
    exception = assert_raises(RuntimeError){
      @recipe.download
    }
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

    data_file = File.expand_path(File.join(File.dirname(__FILE__), 'assets', 'gpg-fixtures', 'data'))

    @recipe.files << {
      :url => "file://#{data_file}",
      :gpg => {
        :key => key,
        :signature => signature
      }
    }
    exception = assert_raises(RuntimeError){ @recipe.download }
    assert_equal("invalid gpg key provided", exception.message)
  end
end

