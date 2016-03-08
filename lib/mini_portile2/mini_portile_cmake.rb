require 'mini_portile2/mini_portile'

class MiniPortileCMake < MiniPortile
  def configure_prefix
    "-DCMAKE_INSTALL_PREFIX=#{File.expand_path(port_path)}"
  end

  def configure_defaults
    if MiniPortile.windows?
      ['-G "NMake Makefiles"']
    else
      []
    end
  end

  def configure
    return if configured?

    md5_file = File.join(tmp_path, 'configure.md5')
    digest   = Digest::MD5.hexdigest(computed_options.to_s)
    File.open(md5_file, "w") { |f| f.write digest }

    execute('configure', %w(cmake) + computed_options + ["."])
  end

  def configured?
    configure = File.join(work_path, 'configure')
    makefile  = File.join(work_path, 'CMakefile')
    md5_file  = File.join(tmp_path, 'configure.md5')

    stored_md5  = File.exist?(md5_file) ? File.read(md5_file) : ""
    current_md5 = Digest::MD5.hexdigest(computed_options.to_s)

    (current_md5 == stored_md5) && newer?(makefile, configure)
  end

  def make_cmd
    return "nmake" if MiniPortile.windows?
    super
  end
end