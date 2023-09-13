require File.expand_path('../helper', __FILE__)

require "mkmf" # initialize $LDFLAGS et al here, instead of in the middle of a test

class TestMkmfConfig < TestCase
  attr_reader :recipe, :include_path, :lib_path

  LIBXML_PCP = File.join(__dir__, "assets", "pkgconf", "libxml2")
  LIBXSLT_PCP = File.join(__dir__, "assets", "pkgconf", "libxslt")

  def setup
    super

    @save_env = %w[PATH CPATH LIBRARY_PATH LDFLAGS PKG_CONFIG_PATH].inject({}) do |env, var|
      env.update(var => ENV[var])
    end
    $INCFLAGS = "-I/xxx"
    $LIBPATH = ["xxx"]
    $CFLAGS = "-xxx"
    $CXXFLAGS = "-xxx"
    $libs = "-lxxx"

    FileUtils.rm_rf(["tmp", "ports"]) # remove any previous test files

    @recipe = MiniPortile.new("libfoo", "1.0.0").tap do |recipe|
      recipe.logger = StringIO.new
    end
    @include_path = File.join(@recipe.path, "include")
    @lib_path = File.join(@recipe.path, "lib")
  end

  def teardown
    FileUtils.rm_rf(["tmp", "ports"]) # remove any previous test files

    $INCFLAGS = ""
    $LIBPATH = []
    $CFLAGS = ""
    $CXXFLAGS = ""
    $libs = ""
    @save_env.each do |var, val|
      ENV[var] = val
    end

    super
  end

  def test_mkmf_config_recipe_LIBPATH_global_lib_dir_does_not_exist
    recipe.mkmf_config

    refute_includes($LIBPATH, lib_path)
    refute_includes($libs.split, "-lfoo")
  end

  def test_mkmf_config_recipe_LIBPATH_global
    FileUtils.mkdir_p(lib_path)

    recipe.mkmf_config

    assert_includes($LIBPATH, lib_path)
    assert_operator($LIBPATH.index(lib_path), :<, $LIBPATH.index("xxx")) # prepend

    assert_includes($libs.split, "-lfoo") # note the recipe name is "libfoo"
    assert_match(%r{-lxxx.*-lfoo}, $libs) # append
  end

  def test_mkmf_config_recipe_INCFLAGS_global_include_dir_does_not_exist
    recipe.mkmf_config

    refute_includes($INCFLAGS.split, "-I#{include_path}")
  end

  def test_mkmf_config_recipe_INCFLAGS_global
    FileUtils.mkdir_p(include_path)

    recipe.mkmf_config

    assert_includes($INCFLAGS.split, "-I#{include_path}")
    assert_match(%r{-I#{include_path}.*-I/xxx}, $INCFLAGS) # prepend
  end

  def test_mkmf_config_pkgconf_does_not_exist
    assert_raises(ArgumentError) do
      recipe.mkmf_config(pkg: "foo")
    end
  end

  def test_mkmf_config_pkgconf_LIBPATH_global
    # can't get the pkgconf utility to install on windows with ruby 2.3 in CI
    skip if MiniPortile.windows? && RUBY_VERSION < "2.4"

    recipe.mkmf_config(pkg: "libxml-2.0", dir: LIBXML_PCP)

    assert_includes($LIBPATH, "/foo/libxml2/2.11.5/lib")
    assert_operator($LIBPATH.index("/foo/libxml2/2.11.5/lib"), :<, $LIBPATH.index("xxx")) # prepend

    assert_includes($libs.split, "-lxml2")
    assert_match(%r{-lxxx.*-lxml2}, $libs) # append
  end

  def test_mkmf_config_pkgconf_CFLAGS_global
    # can't get the pkgconf utility to install on windows with ruby 2.3 in CI
    skip if MiniPortile.windows? && RUBY_VERSION < "2.4"

    recipe.mkmf_config(pkg: "libxml-2.0", dir: LIBXML_PCP)

    assert_includes($INCFLAGS.split, "-I/foo/libxml2/2.11.5/include/libxml2")
    assert_match(%r{-I/foo/libxml2/2.11.5/include/libxml2.*-I/xxx}, $INCFLAGS) # prepend

    assert_includes($CFLAGS.split, "-ggdb3")
    assert_match(%r{-xxx.*-ggdb3}, $CFLAGS) # prepend

    assert_includes($CXXFLAGS.split, "-ggdb3")
    assert_match(%r{-xxx.*-ggdb3}, $CXXFLAGS) # prepend
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

    $INCFLAGS.split.tap do |incflags|
      assert_includes(incflags, "-I/foo/libxml2/2.11.5/include/libxml2")
      assert_includes(incflags, "-I/foo/libxslt/1.1.38/include")
    end
    assert_includes($LIBPATH, "/foo/libxml2/2.11.5/lib")
    assert_includes($LIBPATH, "/foo/libxslt/1.1.38/lib")
    assert_includes($LIBPATH, "/foo/zlib/1.3/lib") # from `--static`
    $CFLAGS.split.tap do |cflags|
      assert_includes(cflags, "-ggdb3")
      assert_includes(cflags, "-Wno-deprecated-enum-enum-conversion")
    end
    $libs.split.tap do |libflags|
      assert_includes(libflags, "-lxml2")
      assert_includes(libflags, "-lxslt")
      assert_includes(libflags, "-lexslt")
      assert_includes(libflags, "-lz") # from `--static`
    end
  end
end
