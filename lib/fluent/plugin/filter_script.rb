module Fluent
  class ScriptFilter < Filter
    Plugin.register_filter('script', self)

    config_param :path, :string

    def configure(conf)
      super
      load_script_file(conf['path'].to_s)
    end

    def load_script_file(path)
      raise ConfigError, "Ruby script file does not exist: #{path}" unless File.exist?(path)
      eval "self.instance_eval do;" + IO.read(path) + ";end"
    end
  end
end

