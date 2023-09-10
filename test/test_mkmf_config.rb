require File.expand_path('../helper', __FILE__)

class TestMkmfConfig < TestCase
  attr_reader :recipe, :include_path, :lib_path

  LIBXML_PCP = File.join(__dir__, "assets", "pkgconf", "libxml2")
  LIBXSLT_PCP = File.join(__dir__, "assets", "pkgconf", "libxslt")

  def setup
    super

    @save_env = %w[PATH CPATH LIBRARY_PATH LDFLAGS PKG_CONFIG_PATH].inject({}) do |env, var|
      env.update(var => ENV[var])
    end
    $LDFLAGS = ""
    $CFLAGS = ""

    FileUtils.rm_rf(["tmp", "ports"]) # remove any previous test files

    @recipe = MiniPortile.new("libfoo", "1.0.0").tap do |recipe|
      recipe.logger = StringIO.new
    end
    @include_path = File.join(@recipe.path, "include")
    @lib_path = File.join(@recipe.path, "lib")
  end

  def teardown
    FileUtils.rm_rf(["tmp", "ports"]) # remove any previous test files

    $LDFLAGS = ""
    $CFLAGS = ""
    @save_env.each do |var, val|
      ENV[var] = val
    end

    super
  end

  def test_mkmf_config_recipe_LDFLAGS_global_lib_dir_does_not_exist
    recipe.mkmf_config

    refute_includes($LDFLAGS.split, "-L#{lib_path}")
    refute_includes($LDFLAGS.split, "-lfoo")
  end

  def test_mkmf_config_recipe_LDFLAGS_global
    FileUtils.mkdir_p(lib_path)

    recipe.mkmf_config

    assert_includes($LDFLAGS.split, "-L#{lib_path}")
    assert_includes($LDFLAGS.split, "-lfoo") # note the recipe name is "libfoo"
  end

  def test_mkmf_config_recipe_CFLAGS_global_include_dir_does_not_exist
    recipe.mkmf_config

    refute_includes($CFLAGS.split, "-I#{include_path}")
  end

  def test_mkmf_config_recipe_CFLAGS_global
    FileUtils.mkdir_p(include_path)

    recipe.mkmf_config

    assert_includes($CFLAGS.split, "-I#{include_path}")
  end

  def test_mkmf_config_pkgconf_does_not_exist
    assert_raises(ArgumentError) do
      recipe.mkmf_config(pkg: "foo")
    end
  end

  def test_mkmf_config_pkgconf_LDFLAGS_global
    # can't get the pkgconf utility to install on windows with ruby 2.3 in CI
    skip if MiniPortile.windows? && RUBY_VERSION < "2.4"

    recipe.mkmf_config(pkg: "libxml-2.0", dir: LIBXML_PCP)

    assert_includes($LDFLAGS.split, "-L/foo/libxml2/2.11.5/lib")
    assert_includes($LDFLAGS.split, "-lxml2")
  end

  def test_mkmf_config_pkgconf_CFLAGS_global
    # can't get the pkgconf utility to install on windows with ruby 2.3 in CI
    skip if MiniPortile.windows? && RUBY_VERSION < "2.4"

    recipe.mkmf_config(pkg: "libxml-2.0", dir: LIBXML_PCP)

    assert_includes($CFLAGS.split, "-I/foo/libxml2/2.11.5/include/libxml2")
  end

  def test_mkmf_config_pkgconf_path_accumulation
    # can't get the pkgconf utility to install on windows with ruby 2.3 in CI
    skip if MiniPortile.windows? && RUBY_VERSION < "2.4"

    (ENV["PKG_CONFIG_PATH"] || "").split(File::PATH_SEPARATOR).tap do |pcpaths|
      refute_includes(pcpaths, LIBXML_PCP)
      refute_includes(pcpaths, LIBXSLT_PCP)
    end

    recipe.mkmf_config(pkg: "libxml-2.0", dir: LIBXML_PCP)

    ENV["PKG_CONFIG_PATH"].split(File::PATH_SEPARATOR).tap do |pcpaths|
      assert_includes(pcpaths, LIBXML_PCP)
      refute_includes(pcpaths, LIBXSLT_PCP)
    end

    recipe.mkmf_config(pkg: "libxslt", dir: LIBXSLT_PCP)

    ENV["PKG_CONFIG_PATH"].split(File::PATH_SEPARATOR).tap do |pcpaths|
      assert_includes(pcpaths, LIBXML_PCP)
      assert_includes(pcpaths, LIBXSLT_PCP)
    end

    recipe.mkmf_config(pkg: "libexslt", dir: LIBXSLT_PCP)

    $CFLAGS.split.tap do |cflags|
      assert_includes(cflags, "-I/foo/libxml2/2.11.5/include/libxml2")
      assert_includes(cflags, "-I/foo/libxslt/1.1.38/include")
    end
    $LDFLAGS.split.tap do |ldflags|
      assert_includes(ldflags, "-L/foo/libxml2/2.11.5/lib")
      assert_includes(ldflags, "-lxml2")
      assert_includes(ldflags, "-L/foo/libxslt/1.1.38/lib")
      assert_includes(ldflags, "-lxslt")
      assert_includes(ldflags, "-lexslt")
      assert_includes(ldflags, "-L/foo/zlib/1.3/lib") # from `--static`
      assert_includes(ldflags, "-lz") # from `--static`
    end
  end
end
