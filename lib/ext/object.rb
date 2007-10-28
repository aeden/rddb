# Extensions to the Object class.
class Object #:nodoc:
  # Example:
  #
  #   returning Hash.new do |hash|
  #     hash['foo'] = 'bar'
  #   end
  def returning(value)
    yield(value)
    value
  end
  
  # Walk through a Hash, recursively converting all keys to symbols.
  def to_sym_key_hash
    case self
    when Hash
      returning Hash.new do |hash|
        self.each do |key, value|
          value = value.to_sym_key_hash if value.is_a?(Hash)
          hash[key.to_sym] = value.to_sym_key_hash
        end
      end
    else
      self
    end
  end
  alias :to_options :to_sym_key_hash
end