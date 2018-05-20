
require 'fluent/plugin/output'

module Fluent
  module Plugin
    class RaygunOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output('raygun', self)

      config_param :api_key, :string
      config_param :default_level, :string, default: 'error'
      config_param :default_logger, :string, default: 'fluentd'
      config_param :endpoint_url, :string, default: 'https://api.raygun.com'
      config_param :flush_interval, :time, default: 0
      config_param :hostname_command, :string, default: 'hostname'
      config_param :record_already_formatted, :bool, default: false

      def write(chunk)
        byebug
        raise 'cats'
      end
    end
  end
end
