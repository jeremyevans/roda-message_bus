Gem::Specification.new do |s|
  s.name = 'roda-message_bus'
  s.version = '1.0.0'
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG", "MIT-LICENSE"]
  s.rdoc_options += ["--quiet", "--line-numbers", "--inline-source", '--title', 'roda-message_bus: MessageBus integration for Roda', '--main', 'README.rdoc']
  s.license = "MIT"
  s.summary = "MessageBus integration for Roda"
  s.author = "Jeremy Evans"
  s.email = "code@jeremyevans.net"
  s.homepage = "https://github.com/jeremyevans/roda-message_bus"
  s.files = %w(MIT-LICENSE CHANGELOG README.rdoc) + Dir["lib/**/*.rb"]
  s.description = <<END
roda-message_bus integrates message_bus into the roda web toolkit,
allowing you to call message_bus only for specific paths, after
any access control checks have been made.
END
  s.add_dependency('message_bus', '>=2.0.0')
  s.add_dependency('roda', '>=2.0.0')
  s.add_development_dependency('minitest')
  s.add_development_dependency "minitest-global_expectations"
end
