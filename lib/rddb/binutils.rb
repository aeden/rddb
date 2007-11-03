module Rddb #:nodoc:
  # Module for utilities used by the RDDB binaries. Not for external 
  # consumption.
  module Binutils #:nodoc:
    # Load the configuration from ENV['HOME']/.rddb
    def load_config
      search_paths = []
      begin
        config_directory = File.join(ENV['HOME'], '.rddb')
        File.makedirs(config_directory) unless File.directory?(config_directory)
        config_file = File.join(config_directory, 'config.yml')
        search_paths << config_file
        unless File.exist?(config_file)
          config_file = File.dirname(__FILE__) + '/../config.yml'
          search_paths << config_file
        end
        YAML.load_file(config_file).to_options
      rescue Errno::ENOENT => e
        raise "Configuration not found in: #{search_paths.join(',')}"
      end
    end
  end
end