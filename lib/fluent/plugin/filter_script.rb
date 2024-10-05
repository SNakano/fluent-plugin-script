require 'fluent/plugin/filter'

module Fluent::Plugin
  class ScriptFilter < Filter
    Fluent::Plugin.register_filter('script', self)

    config_param :path, :string

    def configure(conf)
      super
      load_script_file(conf['path'].to_s)
    end

    def load_script_file(path)
      path = "#{ENV['FLUENT_PLUGIN_SCRIPT_DIR']}/#{path}" if path[0] != '/' && ENV['FLUENT_PLUGIN_SCRIPT_DIR']
      raise Fluent::ConfigError, "Ruby script file does not exist: #{path}" unless File.exist?(path)
      eval "self.instance_eval do;" + IO.read(path) + ";\nend"
    end

    def filter(tag, time, record)
      # Overwritten by evaluated script.
    end
  end
end
