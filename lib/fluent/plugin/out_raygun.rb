class Fluent::RaygunOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('raygun', self)

  include Fluent::HandleTagNameMixin

  LOG_LEVEL = %w(fatal error warning info debug)
  EVENT_KEYS = %w(message timestamp time_spent level logger culprit server_name release tags)
  DEFAULT_HOSTNAME_COMMAND = 'hostname'

  config_param :default_level, :string, :default => 'error'
  config_param :default_logger, :string, :default => 'fluentd'
  config_param :endpoint_url, :string, :default => 'https://api.raygun.com'
  config_param :api_key, :string
  config_param :flush_interval, :time, :default => 0
  config_param :hostname_command, :string, :default => 'hostname'

  def initialize
    require 'time'
    require 'raygun4ruby'

    super
  end

  def configure(conf)
    super

    if @endpoint_url.nil?
      raise Fluent::ConfigError, "Raygun: missing parameter for 'endpoint_url'"
    end

    unless LOG_LEVEL.include?(@default_level)
      raise Fluent::ConfigError, "Raygun: unsupported default reporting log level for 'default_level'"
    end

    hostname_command = @hostname_command || DEFAULT_HOSTNAME_COMMAND
    @hostname = `#{hostname_command}`.chomp

    Raygun.setup do |config|
      config.api_key = @api_key
      config.filter_parameters = [ :password, :card_number, :cvv ] # don't forget to filter out sensitive parameters
      config.enable_reporting = true # true to send errors, false to not log
    end
  end

  def start
    super
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def shutdown
    super
  end

  def write(chunk)
    chunk.msgpack_each do |tag, time, record|
      begin
        notify_raygun(tag, time, record)
      rescue => e
        $log.error("Raygun Error:", :error_class => e.class, :error => e.message)
      end
    end
  end

  def notify_raygun(tag, time, record)
    #TODO: Create error object, also verify this tag creation will work
    #TODO: error should use the message from record['message']
    #TODO: Can we set other properties on what is being sent, like time occurred?

    Raygun.track_exception(e, tags: { :tag => tag }.merge(record['tags'] || {}))
  end
end
