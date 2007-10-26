# Source file containing the Rddb::VERSION module definition. Used
# to indicate what version of Rddb is running.
module Rddb #:nodoc:
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 1
    TINY  = 0

    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end
