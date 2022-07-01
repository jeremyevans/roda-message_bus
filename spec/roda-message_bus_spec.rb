if ENV.delete('COVERAGE')
  require 'simplecov'

  SimpleCov.start do
    enable_coverage :branch
    add_filter "/spec/"
    add_group('Missing'){|src| src.covered_percent < 100}
    add_group('Covered'){|src| src.covered_percent == 100}
  end
end

require 'roda'
require 'message_bus'
require 'json'
ENV['MT_NO_PLUGINS'] = '1' # Work around stupid autoloading of plugins
require 'minitest/global_expectations/autorun'

$: << File.join(File.dirname(File.dirname(__FILE__)), 'lib')

describe 'roda message_bus plugin' do
  def req(path, input={}, env={})
    env = {"PATH_INFO"=>path, "REQUEST_METHOD" => "GET", "SCRIPT_NAME" => "", 'rack.input'=>true, 'rack.request.form_input'=>true, 'rack.request.form_hash'=>input}.merge(env)
    @app.call(env)
  end

  def body(path, input={}, env={})
    s = String.new
    b = req(path, input, env)[2]
    b.each{|x| s << x}
    b.close if b.respond_to?(:close)
    s
  end

  def json_body(path, input={}, env={})
    JSON.parse(body(path, input, env))
  end

  before do
    @app = Class.new(Roda)
    @bus = MessageBus::Instance.new
    @bus.configure(:backend => :memory)
    @app.plugin :message_bus, :message_bus=>@bus
    @app
  end

  it "should handle message bus under a branch" do
    @app.route do |r|
      r.on "foo" do
        r.message_bus
        'bar'
      end
    end

    body('/foo').must_equal 'bar'
    json_body('/foo/message-bus/1/poll', '/foo'=>'0', '__seq'=>1).must_equal []
    @bus.publish '/foo', 'baz'
    json_body('/foo/message-bus/1/poll', '/foo'=>'0', '__seq'=>1).must_equal [{"global_id"=>1, "message_id"=>1, "channel"=>"/foo", "data"=>"baz"}]
    @bus.publish '/foo', 'baz1'
    json_body('/foo/message-bus/1/poll', '/foo'=>'0', '__seq'=>1).must_equal [{"global_id"=>1, "message_id"=>1, "channel"=>"/foo", "data"=>"baz"}, {"global_id"=>2, "message_id"=>2, "channel"=>"/foo", "data"=>"baz1"}]
    json_body('/foo/message-bus/1/poll', '/foo'=>'1', '__seq'=>1).must_equal [{"global_id"=>2, "message_id"=>2, "channel"=>"/foo", "data"=>"baz1"}]
    json_body('/foo/message-bus/1/poll', '/foo'=>'1').must_equal [{"global_id"=>2, "message_id"=>2, "channel"=>"/foo", "data"=>"baz1"}]
    json_body('/foo/message-bus/1/poll', '/bar'=>'0', '__seq'=>1).must_equal []
  end

  it "should handle message bus with specific channels" do
    @app.route do |r|
      r.on "foo" do
        r.message_bus('/foo')
        'bar'
      end
    end

    body('/foo').must_equal 'bar'
    json_body('/foo/message-bus/1/poll', '/foo'=>'0', '__seq'=>1).must_equal []
    @bus.publish '/foo', 'baz'
    json_body('/foo/message-bus/1/poll', '/foo'=>'0', '__seq'=>1).must_equal [{"global_id"=>1, "message_id"=>1, "channel"=>"/foo", "data"=>"baz"}]
    @bus.publish '/foo', 'baz1'
    json_body('/foo/message-bus/1/poll', '/foo'=>'0', '__seq'=>1).must_equal [{"global_id"=>1, "message_id"=>1, "channel"=>"/foo", "data"=>"baz"}, {"global_id"=>2, "message_id"=>2, "channel"=>"/foo", "data"=>"baz1"}]
    json_body('/foo/message-bus/1/poll', '/foo'=>'1', '__seq'=>1).must_equal [{"global_id"=>2, "message_id"=>2, "channel"=>"/foo", "data"=>"baz1"}]
    json_body('/foo/message-bus/1/poll', '/foo'=>'1').must_equal [{"global_id"=>2, "message_id"=>2, "channel"=>"/foo", "data"=>"baz1"}]
    json_body('/foo/message-bus/1/poll', '/bar'=>'0', '__seq'=>1).must_equal []
  end

  it "should support block passed to r.message_bus" do
    @app.route do |r|
      r.on "foo" do
        r.message_bus do
          r.POST['__seq'] = 1
        end
        "bar#{r.POST['__seq']}"
      end
    end

    body('/foo').must_equal 'bar'
    json_body('/foo/message-bus/1/poll', '/foo'=>'0').must_equal []
    @bus.publish '/foo', 'baz'
    json_body('/foo/message-bus/1/poll', '/foo'=>'0').must_equal [{"global_id"=>1, "message_id"=>1, "channel"=>"/foo", "data"=>"baz"}]
    @bus.publish '/foo', 'baz1'
    json_body('/foo/message-bus/1/poll', '/foo'=>'0').must_equal [{"global_id"=>1, "message_id"=>1, "channel"=>"/foo", "data"=>"baz"}, {"global_id"=>2, "message_id"=>2, "channel"=>"/foo", "data"=>"baz1"}]
    json_body('/foo/message-bus/1/poll', '/foo'=>'1').must_equal [{"global_id"=>2, "message_id"=>2, "channel"=>"/foo", "data"=>"baz1"}]
  end
end
