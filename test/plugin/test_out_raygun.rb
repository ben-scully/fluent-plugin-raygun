require 'test_helper'
require 'fluent/test/driver/output'
require 'fluent/plugin/out_raygun'

class RaygunOutputTest < Test::Unit::TestCase
  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::RaygunOutput).configure(conf)
  end

  def setup
    Fluent::Test.setup
  end

  CONFIG = %(
    type raygun
    endpoint_url      https://api.raygun.com
    api_key           abc123
    hostname_command  hostname -s
    remove_tag_prefix input.
  ).freeze

  sub_test_case 'configure' do
    test 'empty' do
      assert_raise(Fluent::ConfigError) do
        create_driver('')
      end
    end
  end
end
