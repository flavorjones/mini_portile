require "rake/clean"
require 'bundler/gem_tasks'

desc "Test MiniPortile by compiling examples"
task :test do
  Dir.chdir("examples") do
    sh "rake ports:all"
  end
end

task :default => [:test]
