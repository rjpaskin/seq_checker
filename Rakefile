require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*/*_test.rb']
end

task :cleanup do
  require 'fileutils'
  FileUtils.rmtree Dir['filestore/*']
end

task :default => :test