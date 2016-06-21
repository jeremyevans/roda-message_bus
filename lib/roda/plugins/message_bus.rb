# frozen-string-literal: true

require 'message_bus/rack/middleware'

class Roda
  module RodaPlugins
    # The message_bus plugin allows for integrating the message_bus library into
    # Roda's routing tree.  By default, MessageBus provides a Rack middlware to
    # work with any rack framework.  However, that doesn't work well if you are
    # integrating access control into your routing tree.
    #
    # With the message_bus plugin, you can specify exactly where to pass control
    # to message_bus, which can be done after access controls have been checked.
    # Additionally, this allows to control which message_bus channels are allowed
    # for which requests, further enhancing security.
    #
    # It is still possible to use message_bus's user/group/site filtering when
    # using this support to filter allowed channels.
    #
    #   # Use default MessageBus
    #   plugin :message_bus
    #
    #   # Use specific MessageBus implementation
    #   plugin :message_bus, :message_bus=>MessageBus::Instance.new
    #
    #   route do |r|
    #     r.on "room/:id" do |room_id|
    #       room_id = room_id.to_i
    #       raise unless current_user.has_access?(room_id)
    #
    #       # Uses "/room/#{room_id}" channel by default
    #       r.message_bus
    #
    #       # Override channel to use (can also provide array of channels)
    #       r.message_bus("/room/#{room_id}/enters")
    #
    #       # In addition to subscribing to channels,
    #       # in Javascript on this page, set:
    #       #
    #       #   MessageBus.baseUrl = "/room/<%= room_id %>/"
    #       view('room')
    #     end
    #   end
    module MessageBus
      APP = proc{[404, {"Content-Type" => "text/html"}, ["Not Found"]]}

      def self.configure(app, config={})
        app.opts[:message_bus_app] = ::MessageBus::Rack::Middleware.new(APP, config)
      end

      module ClassMethods
        def message_bus_app
          opts[:message_bus_app]
        end
      end

      module RequestMethods
        def message_bus(channels=nil)
          if remaining_path =~ /\A\/message-bus\//
            chans = env['message_bus.channels'] = {}
            post = self.POST
            channels ||= script_name + path_info.chomp(remaining_path)
            Array(channels).each do |channel|
              if val = post[channel]
                chans[channel] = val
              end
            end
            env['message_bus.seq'] = post['__seq']
            yield if block_given?
            run roda_class.message_bus_app
          end
        end
      end
    end

    register_plugin(:message_bus, MessageBus)
  end
end
