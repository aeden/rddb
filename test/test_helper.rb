require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'
require 'fileutils'
require 'pp'

require File.dirname(__FILE__) + '/../lib/rddb'

basedir = 'data'
if File.directory?(basedir)
  puts "Removing #{basedir}"
  FileUtils.rm_rf(basedir)
end