# Source file containing the Rddb::Document class definition.
module Rddb #:nodoc
  # A document, which is essentially a map of name/value pairs. You can access
  # attributes directly through [] and []=. You may also access attributes for
  # reading by calling a method with the attribute name. For example:
  #
  #   doc = Document.new(:name => 'Bob')
  #   doc[:name]
  #   => 'Bob'
  #   doc.name
  #   => 'Bob'
  class Document
    # Construct a document. You may pass a Hash to prefill the document 
    # attributes. The :id attribute is a special attribute that is used
    # as a unique identifier for storage purposes - if you do not specify
    # a value for :id then a UUID key will be generated.
    def initialize(data={})
      @data = data.to_sym_key_hash
      @data[:id] ||= UUID.new
      # undef_method :type
    end
    
    # Return the Document ID.
    def id
      @data[:id]
    end
    
    # Get the named attribute.
    def [](name)
      @data[name.to_sym]
    end
    
    # Set the named attribute.
    def []=(name, value)
      @data[name.to_sym] = value
    end
    
    # Returns true if the document has the named attribute
    def attribute?(name)
      @data.key?(name)
    end
    
    def method_missing(method, *args) #:nodoc:
      @data[method] if attribute?(method)
    end
    
    # Return true if the two objects are equal
    def ==(o) #:nodoc:
      o.kind_of?(self.class) && self.id.to_s == o.id.to_s
    end
    
    # Return a String representation of the document.
    def to_s #:nodoc:
      inspect
    end
    
    # Return a printable representation of the object.
    def inspect #:nodoc:
      @data.inspect
    end
    
    # Create a representation of the document suitable for sending over HTTP.
    def to_wire
      pairs = []
      @data.each do |name,value|
        pairs << "#{CGI.escape(name.to_s)}=#{CGI.escape(value)}"
      end
      pairs.join('&')
    end
  end
end