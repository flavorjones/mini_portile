require "rake/clean"

namespace :test do
  desc "Test MiniPortile by running unit tests"
  task :unit do
    sh "ruby -w -W2 -I. -Ilib -e \"#{Dir["test/test_*.rb"].map{|f| "require '#{f}';"}.join}\" -- -v"
  end

  desc "Test MiniPortile by compiling examples"
  task :examples do
    Dir.chdir("examples") do
      sh "rake -I../lib ports:all"
    end
  end
end

desc "Run all tests"
task :test => ["test:unit", "test:examples"]

task :default => [:test]
