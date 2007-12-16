module Rddb
  # A module that can be mixed in to a "store" to provide cache access
  module Cacheable
    # Return true if caching is enabled.
    def cache?
      options && !options[:cache].nil?
    end
    
    # Get the cache
    def cache
      @cache ||= options[:cache].new
    end
  end
end