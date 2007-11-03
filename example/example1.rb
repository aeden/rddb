#!/usr/bin/env ruby

require 'yaml'
require 'pp'
require File.dirname(__FILE__) + '/../lib/rddb'

data = YAML.load(File.new(File.dirname(__FILE__) + '/example1.yml'))

db = Rddb::Database.new
data.each { |o| db << o }

db.create_view('all users') do |document|
  if document.doctype == "user"
    {
      :name => "#{document.first_name} #{document.last_name}",
      :email => document.email
    }
  end
end

db.create_view('all users with foobar.com email addresses') do |document|
  if document.doctype == "user" && document.email =~ /\@foobar.com$/
    {
      :name => "#{document.first_name} #{document.last_name}",
      :email => document.email
    }
  end
end

db.create_view('user count') do |document|
  if document.doctype == 'user'
    document
  end
end.reduce_with do |results|
  results.length
end

db.create_view('all documents count') do |document|
  document
end.reduce_with do |results|
  results.length
end

db.create_view('names sorted by last name') do |document|
  document if document.doctype == "user"
end.reduce_with do |results|
  results.sort { |a,b| a.last_name <=> b.last_name }.collect { |document| "#{document.first_name} #{document.last_name}" }
end

db.create_view('names sorted by last name descending') do |document|
  document if document.doctype == "user"
end.reduce_with do |results|
  results.sort { |a,b| a.last_name <=> b.last_name }.collect { |document| "#{document.first_name} #{document.last_name}" }.reverse
end

db.create_view('user by name') do |document|
  document if document.name = name
end

[
  'all users', 
  'all users with foobar.com email addresses',
  'names sorted by last name',
  'names sorted by last name descending',
  'user count', 
  'all documents count'
].each do |name|
  puts "#{name}:"
  pp db.query(name)
  puts
end