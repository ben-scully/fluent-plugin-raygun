require 'helper'
require 'webmock/test_unit'
require 'yajl'

WebMock.disable_net_connect!

class RaygunOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    type raygun
    endpoint_url      https://api.raygun.com
    api_key           abc123
    hostname_command  hostname -s
    remove_tag_prefix input.
  ]

  def create_driver(conf=CONFIG,tag='test',use_v1=false)
    require 'fluent/version'
    if Gem::Version.new(Fluent::VERSION) < Gem::Version.new('0.12')
      Fluent::Test::OutputTestDriver.new(Fluent::RaygunOutput, tag).configure(conf, use_v1)
    else
      Fluent::Test::BufferedOutputTestDriver.new(Fluent::RaygunOutput, tag).configure(conf, use_v1)
    end
  end

end
