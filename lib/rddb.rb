# Require this file to use RDDB.

$:.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'uuid'
require 'daemons'
require 'aws/s3'
require 'mongrel'

require 'rinda/ring'
require 'rinda/tuplespace'

# Configure the UUID class, logging only FATAL messages to STDOUT
uuid_logger = Logger.new(STDOUT)
uuid_logger.level = Logger::FATAL
UUID.config(:logger => uuid_logger)

require 'ext/object'

require 'rddb/document'
require 'rddb/database'
require 'rddb/document_store'
require 'rddb/view_store'
require 'rddb/materialization_store'
require 'rddb/view'
require 'rddb/version'

require 'rddb/server'
require 'rddb/worker'

require 'ext/mongrel'

# Module containing the RDDB classes.
module Rddb
  # Error that is raised if a materialized view is required and the
  # materialization has not yet occured.
  class ViewNotYetMaterialized < RuntimeError
  end
  # Error that is raised when a document is requested from a document store and
  # the document does not exist.
  class DocumentNotFound < RuntimeError
  end
  # Error that is raised when a view is not defined.
  class ViewNotFound < RuntimeError
  end
end