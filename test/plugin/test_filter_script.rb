require 'test/unit'
require 'fluent/log'
require 'fluent/test'
require 'fluent/test/driver/filter'
require 'fluent/plugin/filter_script'

class RubyFilterTest < Test::Unit::TestCase
  include Fluent

  setup do
    Fluent::Test.setup
  end

  def create_driver(conf = '')
    Test::Driver::Filter.new(Plugin::ScriptFilter).configure(conf)
  end

  sub_test_case 'configure' do
    test 'not set required' do
      conf = ''
      assert_raises(ConfigError) { create_driver(conf) }
    end
    test 'wrong file path' do
      conf = 'path /not-exit-ruby-file-path'
      assert_raises(ConfigError) { create_driver(conf) }
    end
    test 'file exist' do
      conf = "path #{__dir__}/example.rb"
      assert_nothing_raised { create_driver(conf) }
    end
    test 'file exist with FLUENT_PLUGIN_SCRIPT_DIR' do
      ENV['FLUENT_PLUGIN_SCRIPT_DIR'] = __dir__
      conf = 'path example.rb'
      assert_nothing_raised { create_driver(conf) }
    end
  end

  sub_test_case 'filter' do
    def emit(conf, msg)
      d = create_driver(conf)
      d.run(default_tag: 'test') {
        d.feed(Fluent::Engine.now, {'foo' => 'bar', 'message' => msg})
      }
      d.filtered
    end
    test 'execute filter' do
      conf = "path #{__dir__}/example.rb"
      msg  = "2015/02/10T01:10:20.123456 INFO GET /ping"
      es   = emit(conf, msg)
      assert_equal("2015/02/10T01:10:20.123456 INFO PUT /ping", es.first[1]['message'])
    end
  end
end
