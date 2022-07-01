require "rake/clean"

CLEAN.include ["roda-message_bus-*.gem", "rdoc", "coverage"]

desc "Build thamble gem"
task :package=>[:clean] do |p|
  sh %{#{FileUtils::RUBY} -S gem build roda-message_bus.gemspec}
end

### Specs

desc "Run specs"
task :spec do
  sh "#{FileUtils::RUBY} #{"-w" if RUBY_VERSION >= '3'} -I lib spec/roda-message_bus_spec.rb"
end

task :default => :spec

### RDoc

require "rdoc/task"

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += ['--inline-source', '--line-numbers', '--title', 'roda-message_bus: MessageBus integration for Roda', '--main', 'README.rdoc', '-f', 'hanna']
  rdoc.rdoc_files.add %w"README.rdoc CHANGELOG MIT-LICENSE lib/**/*.rb"
end

