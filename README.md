# MiniPortile

![build status](https://travis-ci.org/flavorjones/mini_portile.svg?branch=master)

* [Source Code](https://github.com/flavorjones/mini_portile)
* [Bug Reports](https://github.com/flavorjones/mini_portile/issues)

This project is a minimalistic, simplistic and stupid implementation of a port/recipe
system **for developers**.


## Another port system, srsly?

No, `mini_portile` is not a general port system. It is not aimed to
take over apt, macports or anything like that.

The rationale is simple.

You create a library A that uses B at runtime or compile time. Target audience
of your library might have different versions of B installed than yours.

You know, _"Works on my machine"_ is not what you expect from one
developer to another.

Developers having problems report them back to you, and what you do then?
Compile B locally, replacing your existing installation of B or simply hacking
things around so nothing breaks.

All this, manually.

Computers are tools, are meant to help us, not the other way around.

What if I tell you the above scenario can be simplified with something like
this:

```
rake compile B_VERSION=1.2.3
```

And your library will use the version of B you specified. Done.


## You make it sound easy, where is the catch?

You got me, there is a catch. At this time (and highly likely will be
always) `MiniPortile` is only compatible with GCC compilers and
autoconf/configure-based projects.

It assumes the library you want to build contains a `configure`
script, which all the autoconf-based libraries do.


### How to use

Now that you know the catch, and you're still reading this, let me
show you a quick example:

```ruby
require "mini_portile"
recipe = MiniPortile.new("libiconv", "1.13.1")
recipe.files = ["http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.13.1.tar.gz"]
recipe.cook
recipe.activate
```

That's all. `#cook` will download, extract, patch, configure and
compile the library into a namespaced structure. `#activate` ensures
GCC will find this library and prefer it over a system-wide
installation.


### Structure

`MiniPortile` follows the principle of **convention over configuration** and
established a folder structure where is going to place files and perform work.

Take the above example, and let's draw some picture:

```
  mylib
    |-- ports
    |   |-- archives
    |   |   `-- libiconv-1.13.1.tar.gz
    |   `-- <platform>
    |       `-- libiconv
    |           `-- 1.13.1
    |               |-- bin
    |               |-- include
    |               `-- lib
    `-- tmp
        `-- <platform>
            `-- ports
```

In above structure, `platform` refers to the architecture that represents
the operating system you're using (e.g. i686-linux, i386-mingw32, etc).

Inside this folder, `MiniPortile` will store the artifacts that result from the
compilation process. As you can see, it versions out the library so you can
run multiple version combination without compromising these overlap each other.

`archives` is where downloaded source files are stored. It is recommended
you avoid trashing that folder so no further downloads will be required (save
bandwidth, save the world).

`tmp` is where compilation is performed and can be safely discarded.

Use the recipe's `path` to obtain the full path to the installation
directory:

```ruby
recipe.cook
recipe.path # => /home/luis/projects/myapp/ports/i686-linux/libiconv/1.13.1
```

### How can I combine this with my compilation task?

In the simplified proposal, the idea is that using Rake, your
`compile` task depends on `MiniPortile` compilation and most important,
activation.

Take the following as a simplification of how you can use `MiniPortile` with
rake:

```ruby
task :libiconv do
  recipe = MiniPortile.new("libiconv", "1.13.1")
  recipe.files = ["http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.13.1.tar.gz"]
  checkpoint = ".#{recipe.name}-#{recipe.version}.installed"

  unless File.exist?(checkpoint)
    recipe.cook
    touch checkpoint
  end

  recipe.activate
end

task :compile => [:libiconv] do
  # ...
end
```

The above example will:

* Compile the library only once (using a timestamp file)
* Ensure compiled library gets activated every time
* Make compile task depend on compiled library activation

For your homework, you can make libiconv version be taken from `ENV`
variables or a configuration file.


### Native or cross-compilation

The above example covers the normal use case: compile support
libraries natively.

`MiniPortile` also covers another use case, which is the
cross-compilation of the support libraries to be used as part of a
binary gem compilation.

It is the perfect complementary tool for
[`rake-compiler`](https://github.com/rake-compiler/rake-compiler) and
its `cross` rake task.

Depending on your usage of `rake-compiler`, you will need to use
`host` to match the installed cross-compiler toolchain.

Please refer to the examples directory for simplified and practical usage.


### Supported scenarios

As mentioned before, MiniPortile requires a GCC compiler toolchain. This has
been tested against Ubuntu, OSX and even Windows (RubyInstaller with DevKit)


## License

This library is licensed under MIT license. Please see LICENSE.txt for details.
