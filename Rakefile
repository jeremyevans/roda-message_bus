require "rake"
require "rake/clean"

CLEAN.include ["roda-message_bus-*.gem", "rdoc", "coverage"]

desc "Build thamble gem"
task :package=>[:clean] do |p|
  sh %{#{FileUtils::RUBY} -S gem build roda-message_bus.gemspec}
end

### Specs

desc "Run specs"
task :spec do
  sh "#{FileUtils::RUBY} -rubygems -I lib spec/roda-message_bus_spec.rb"
end

task :default => :spec

### RDoc

RDOC_OPTS = ["--quiet", "--line-numbers", "--inline-source", '--main', 'README.rdoc', '--title', 'roda-message_bus: MessageBus integration for Roda']

begin
  gem 'hanna-nouveau'
  RDOC_OPTS.concat(['-f', 'hanna'])
rescue Gem::LoadError
end

require "rdoc/task"

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += RDOC_OPTS
  rdoc.rdoc_files.add %w"README.rdoc CHANGELOG MIT-LICENSE lib/**/*.rb"
end
