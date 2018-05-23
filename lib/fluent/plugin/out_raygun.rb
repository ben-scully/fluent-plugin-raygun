class Fluent::RaygunOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('raygun', self)

  include Fluent::HandleTagNameMixin

  LOG_LEVEL = %w[fatal error warning info debug].freeze
  EVENT_KEYS = %w[message timestamp time_spent level logger culprit server_name release tags].freeze
  DEFAULT_HOSTNAME_COMMAND = 'hostname'.freeze

  config_param :default_level, :string, default: 'error'
  config_param :default_logger, :string, default: 'fluentd'
  config_param :endpoint_url, :string, default: 'https://api.raygun.com'
  config_param :api_key, :string
  config_param :flush_interval, :time, default: 0
  config_param :hostname_command, :string, default: 'hostname'
  config_param :record_already_formatted, :bool, default: false

  def initialize
    require 'time'

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
  end

  def start
    super

    require 'net/http/persistent'
    require 'uri'

    @uri = URI @endpoint_url
    @http = Net::HTTP::Persistent.new
    @http.headers['Content-Type'] = 'text/json'
    @http.headers['X-ApiKey'] = @api_key
    @http.idle_timeout = 10
    @http.socket_options << [Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, 1]

    log.debug 'Started Raygun fluent shipper..'
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def write(chunk)
    chunk.msgpack_each do |tag, time, record|
      begin
        notify_raygun(tag, time, record)
      rescue StandardError => e
        $log.error('Raygun Error:', error_class: e.class, error: e.message)
      end
    end
  end

  def notify_raygun(tag, time, record)
    payload =
      if @record_already_formatted
        # Setting @record_already_formatted = true, means you
        # are already happy with the formatting of 'record'
        record
      else
        default_payload_format(tag, time, record)
      end

    post = Net::HTTP::Post.new(
      "#{@endpoint_url}/entries?apikey=#{URI.encode(@api_key)}"
    )
    post.body = JSON.generate(payload)

    @http.request(@uri, post)
  end

  def default_payload_format(tag, time, record)
    {
      occurredOn: Time.at(time).utc.iso8601,
      details: {
        machineName: @hostname,
        error: {
          message: record['messages']
        },
        tags: [tag]
      }
    }
  end
end
