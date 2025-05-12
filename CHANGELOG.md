## mini_portile changelog

### 2.8.9 / 2025-05-12

### Ruby support

* Import only what's needed from `cgi`, for supporting Ruby 3.5. #160 @Earlopain


### 2.8.8 / 2024-11-14

#### Improved

- Raise an exception with a clear error message when `xzcat` is needed but is not installed. (#152) @flavorjones


### 2.8.7 / 2024-05-31

#### Added

- When setting the C compiler through the `MiniPortile` constructor, the preferred keyword argument is now `:cc_command`. The original `:gcc_command` is still supported. (#144 by @flavorjones)
- Add support for extracting xz-compressed tarballs on OpenBSD. (#141 by @postmodern)
- Add OpenBSD support to the experimental method `MakeMakefile#mkmf_config`. (#141 by @flavorjones)


#### Changed

- `MiniPortileCMake` now detects the C and C++ compiler the same way `MiniPortile` does: by examining environment variables, then using kwargs, then looking in RbConfig (in that order). (#144 by @flavorjones)
- GPG file verification error messages are captured in the raised exception. Previously these errors went to `stderr`. (#145 by @flavorjones)


### 2.8.6 / 2024-04-14

#### Added

- When using CMake on FreeBSD, default to clang's "cc" and "c++" compilers. (#139 by @mudge)


### 2.8.5 / 2023-10-22

#### Added

- New methods `#lib_path` and `#include_path` which point at the installed directories under `ports`. (by @flavorjones)
- Add config param for CMAKE_BUILD_TYPE, which now defaults to `Release`. (#136 by @Watson1978)

#### Experimental

Introduce experimental support for `MiniPortile#mkmf_config` which sets up MakeMakefile variables to properly link against the recipe. This should make it easier for C extensions to package third-party libraries. (by @flavorjones)

- With no arguments, will set up just `$INCFLAGS`, `$libs`, and `$LIBPATH`.
- Optionally, if provided a pkg-config file, will use that config to more precisely set `$INCFLAGS`, `$libs`, `$LIBPATH`, and `$CFLAGS`/`$CXXFLAGS`.
- Optionally, if provided the name of a static archive, will rewrite linker flags to ensure correct linkage.

Note that the behavior may change slightly before official support is announced. Please comment on [#118](https://github.com/flavorjones/mini_portile/issues/118) if you have feedback.


### 2.8.4 / 2023-07-18

- cmake: set CMAKE compile flags to configure cross-compilation similarly to `autotools` `--host` flag: `SYSTEM_NAME`, `SYSTEM_PROCESSOR`, `C_COMPILER`, and `CXX_COMPILER`. [#130] (Thanks, @stanhu!)


### 2.8.3 / 2023-07-18

#### Fixed

- cmake: only use MSYS/NMake generators when available. [#129] (Thanks, @stanhu!)


### 2.8.2 / 2023-04-30

#### Fixed

- Ensure that the `source_directory` option will work when given a Windows path to an autoconf directory. [#126]


### 2.8.1 / 2022-12-24

#### Fixed

- Support applying patches via `git apply` even when the working directory resembles a git directory. [#119] (Thanks, @h0tw1r3!)


### 2.8.0 / 2022-02-20

#### Added

- Support xz-compressed archives (recognized by an `.xz` file extension).
- When downloading a source archive, default open_timeout and read_timeout to 10 seconds, but allow configuration via open_timeout and read_timeout config parameters.


### 2.7.1 / 2021-10-20

#### Packaging

A test artifact that has been included in the gem was being flagged by some users' security scanners because it wasn't a real tarball. That artifact has been updated to be a real tarball. [#108]


### 2.7.0 / 2021-08-31

#### Added

The commands used for "make", "compile", and "cmake" are configurable via keyword arguments. [#107] (Thanks, @cosmo0920!)


### 2.6.1 / 2021-05-31

#### Dependencies

Make `net-ftp` an optional dependency, since requiring it as a hard dependency in v2.5.2 caused warnings to be emitted by Ruby 2.7 and earlier. A warning message is emitted if FTP functionality is called and `net-ftp` isn't available; this should only happen in Ruby 3.1 and later.


### 2.5.3 / 2021-05-31

#### Dependencies

Make `net-ftp` an optional dependency, since requiring it as a hard dependency in v2.5.2 caused warnings to be emitted by Ruby 2.7 and earlier. A warning message is emitted if FTP functionality is called and `net-ftp` isn't available; this should only happen in Ruby 3.1 and later.


### 2.6.0 / 2021-05-31

### Added

Recipes may build against a local directory by specifying `source_directory` instead of `files`. In
particular, this may be useful for debugging problems with the upstream dependency (e.g., use `git
bisect` in a local clone) or for continuous integration with upstream HEAD.


### 2.5.2 / 2021-05-28

#### Dependencies

Add `net-ftp` as an explicit dependency to accommodate the upcoming Ruby 3.1 changes that move this and other gems out of the "default" gem set and into the "bundled" gem set. See https://bugs.ruby-lang.org/issues/17873 [#101]


### 2.5.1 / 2021-04-28

#### Dependencies

This release ends support for ruby < 2.3.0. If you're on 2.2.x or earlier, we strongly suggest that you find the time to upgrade, because [official support for Ruby 2.2 ended on 2018-03-31](https://www.ruby-lang.org/en/news/2018/06/20/support-of-ruby-2-2-has-ended/).

#### Enhancements

* `MiniPortile.execute` now takes an optional `:env` hash, which is merged into the environment variables for the subprocess. Likely this is only useful for specialized use cases. [#99]
* Experimental support for cmake-based projects extended to Windows. (Thanks, @larskanis!)


### 2.5.0 / 2020-02-24

#### Enhancements

* When verifying GPG signatures, remove all imported pubkeys from keyring [#90] (Thanks, @hanazuki!)
    

### 2.4.0 / 2018-12-02

#### Enhancements

* Skip progress report when Content-Length is unavailable. [#85] (Thanks, @eagletmt!)


### 2.3.0 / 2017-09-13

#### Enhancements

* Verify checksums of files at extraction time (in addition to at download time). (#56)
* Clarify error message if a `tar` command can't be found. (#81)


### 2.2.0 / 2017-06-04

#### Enhancements

* Remove MD5 hashing of configure options, not avialbale in FIPS mode. (#78)
* Add experimental support for cmake-based projects.
* Retry on HTTP failures during downloads. [#63] (Thanks, @jtarchie and @jvshahid!)
* Support Ruby 2.4 frozen string literals.
* Support applying patches for users with misconfigured git worktree. [#69]
* Support gpg signature verification of download resources.


### 2.1.0 / 2016-01-06

#### Enhancements

* Add support for `file:` protocol for tarballs


#### Bugfixes

* Raise exception on unsupported URI protocols
* Ignore git whitespace config when patching (Thanks, @e2!) (#67)


### 2.0.0 / 2015-11-30

Many thanks to @larskanis, @knu, and @kirikak2, who all contributed
code, ideas, or both to this release.

Note that the 0.7.0.rc* series was not released as 0.7.0 final, and
instead became 2.0.0 due to backwards-incompatible behavioral changes
which can appear because rubygems doesn't enforce loading the declared
dependency version at installation-time (only run-time).

If you use MiniPortile in an `extconf.rb` file, please make sure you're
setting a gem version constraint before `require "mini_portile2"` .

Note also that 2.0.0 doesn't include the backwards-compatible "escaped
string" behavior from 0.7.0.rc3.


#### Enhancements

* In patch task, use git(1) or patch(1), whichever is available.
* Append outputs to patch.log instead of clobbering it for every patch command.
* Take `configure_options` literally without running a subshell.
  This changes allows for embedded spaces in a path, among other things.
  Please unescape `configure_options` where you have been doing it yourself.
* Print last 20 lines of the given log file, for convenience.
* Allow SHA1, SHA256 and MD5 hash verification of downloads


#### Bugfixes

* Fix issue when proxy username/password use escaped characters.
* Fix use of https and ftp proxy.


### 0.7.0.rc4 / 2015-08-24

* Updated tests for Windows. No functional change. Final release candidate?


### 0.7.0.rc3 / 2015-08-24

* Restore backwards-compatible behavior with respect to escaped strings.


### 0.7.0.rc2 / 2015-08-24

* Restore support for Ruby 1.9.2
* Add Ruby 2.0.0 and Ruby 2.1.x to Appveyor suite


### 0.7.0.rc1 / 2015-08-24

Many thanks to @larskanis, @knu, and @kirikak2, who all contributed
code, ideas, or both to this release.

#### Enhancements

* In patch task, use git(1) or patch(1), whichever is available.
* Append outputs to patch.log instead of clobbering it for every patch command.
* Take `configure_options` literally without running a subshell.
  This changes allows for embedded spaces in a path, among other things.
  Please unescape `configure_options` where you have been doing it yourself.
* Print last 20 lines of the given log file, for convenience.
* Allow SHA1, SHA256 and MD5 hash verification of downloads


#### Bugfixes

* Fix issue when proxy username/password use escaped characters.
* Fix use of https and ftp proxy.


### 0.6.2 / 2014-12-30

* Updated gemspec, license and README to reflect new maintainer.


### 0.6.1 / 2014-08-03

* Enhancements:
  * Expand path to logfile to easier debugging on failures.
    Pull #33 [marvin2k]

### 0.6.0 / 2014-04-18

* Enhancements:
  * Add default cert store and custom certs from `SSL_CERT_FILE` if present.
    This increases compatibility with Ruby 1.8.7.

* Bugfixes:
  * Specify Accept-Encoding to make sure a raw file content is downloaded.
    Pull #30. [knu]

* Internal:
  * Improve examples and use them as test harness.

### 0.5.3 / 2014-03-24

* Bugfixes:
  * Shell escape paths in tar command. Pull #29. [quickshiftin]
  * Support older versions of tar that cannot auto-detect
    the compression type. Pull #27. Closes #21. [b-dean]
  * Try RbConfig's CC before fall back to 'gcc'. Ref #28.

### 0.5.2 / 2013-10-23

* Bugfixes:
  * Change tar detection order to support NetBSD 'gtar'. Closes #24
  * Trick 'git-apply' when applying patches on nested Git checkouts. [larskanis]
  * Respect ENV's MAKE before fallback to 'make'. [larskanis]
  * Respect ENV's CC variable before fallback to 'gcc'.
  * Avoid non-ASCII output of GCC cause host detection issues. Closes #22

### 0.5.1 / 2013-07-07

* Bugfixes:
  * Detect tar executable without shelling out. [jtimberman]

### 0.5.0 / 2012-11-17

* Enhancements:
  * Allow patching extracted files using `git apply`. [metaskills]

### 0.4.1 / 2012-10-24

* Bugfixes:
  * Syntax to process FTp binary chunks differs between Ruby 1.8.7 and 1.9.x

### 0.4.0 / 2012-10-24

* Enhancements:
  * Allow fetching of FTP URLs along HTTP ones. [metaskills]

### 0.3.0 / 2012-03-23

* Enhancements:
  * Use `gcc -v` to determine original host (platform) instead of Ruby one.

* Deprecations:
  * Dropped support for Rubies older than 1.8.7

### 0.2.2 / 2011-04-11

* Minor enhancements:
  * Use LDFLAGS when activating recipes for cross-compilation. Closes #6

* Bugfixes:
  * Remove memoization of *_path helpers. Closes #7

### 0.2.1 / 2011-04-06

* Minor enhancements:
  * Provide MiniPortile#path to obtain full path to installation directory. Closes GH-5

### 0.2.0 / 2011-04-05

* Enhancements:
  * Improve tar detection
  * Improve and refactor configure_options
  * Detect configure_options changes. Closes GH-1
  * Add recipe examples

* Bugfixes:
  * MiniPortile#target can be changed now. Closes GH-2
  * Always redirect tar output properly

### 0.1.0 / 2011-03-08

* Initial release. Welcome to this world!
