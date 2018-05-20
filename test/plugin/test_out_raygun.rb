require 'test_helpers'
require 'fluent/test/driver/output'
require 'fluent/plugin/out_raygun'

require 'byebug'

class RaygunOutputTest < Test::Unit::TestCase
  TEST_CONFIG = %(
    default_level             test_error
    default_logger            test_lgger
    endpoint_url              test_url
    api_key                   test_api_key
    flush_interval            test_flush_interval
    hostname_command          test_hostname_command
    record_already_formatted  test_record_already_formatted
  ).freeze

  CONFIG = %(
    endpoint_url      https://api.raygun.com
    api_key           abc123
    hostname_command  hostname
  ).freeze

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::RaygunOutput).configure(conf)
  end

  def setup
    Fluent::Test.setup
  end

  sub_test_case 'configure' do
    test 'empty' do
      assert_raise(Fluent::ConfigError) do
        create_driver('')
      end
    end

    test 'no api_key' do
      assert_raise(Fluent::ConfigError) do
        create_driver('endpoint_url http://google.com')
      end
    end

    test 'complete' do
      create_driver(TEST_CONFIG)
    end
  end

  sub_test_case 'configure' do
    test 'emit' do
      d = create_driver(CONFIG)
      time = Fluent::EventTime.new(5)
      d.run(default_tag: 'test') do
        d.feed(time, {"message" => "message1"})
        d.feed(time, {"message" => "message2"})
      end
      # byebug
      assert_equal(1, d.events.size)
    end
  end
end
