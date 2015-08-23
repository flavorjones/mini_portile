require "rake/clean"

desc "Test MiniPortile by compiling examples"
task :test do
  Dir.chdir("examples") do
    sh "rake ports:all"
  end
end

task :clean do
  FileUtils.rm_rf ["examples/ports", "examples/tmp"], :verbose => true
end

task :default => [:test]
