require 'roda'
require 'message_bus'
require 'json'
require 'minitest/autorun'

MessageBus.configure(:backend => :memory)

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
    @app.plugin :message_bus
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
    MessageBus.publish '/foo', 'baz'
    json_body('/foo/message-bus/1/poll', '/foo'=>'0', '__seq'=>1).must_equal [{"global_id"=>1, "message_id"=>1, "channel"=>"/foo", "data"=>"baz"}]
    MessageBus.publish '/foo', 'baz1'
    json_body('/foo/message-bus/1/poll', '/foo'=>'0', '__seq'=>1).must_equal [{"global_id"=>1, "message_id"=>1, "channel"=>"/foo", "data"=>"baz"}, {"global_id"=>2, "message_id"=>2, "channel"=>"/foo", "data"=>"baz1"}]
    json_body('/foo/message-bus/1/poll', '/foo'=>'1', '__seq'=>1).must_equal [{"global_id"=>2, "message_id"=>2, "channel"=>"/foo", "data"=>"baz1"}]
    json_body('/foo/message-bus/1/poll', '/foo'=>'1').must_equal [{"global_id"=>2, "message_id"=>2, "channel"=>"/foo", "data"=>"baz1"}]
  end
end
