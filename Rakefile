require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'

require File.join(File.dirname(__FILE__), 'lib/rddb')

PKG_BUILD       = ENV['PKG_BUILD'] ? '.' + ENV['PKG_BUILD'] : ''
PKG_NAME        = 'rddb'
PKG_VERSION     = Rddb::VERSION::STRING + PKG_BUILD
PKG_FILE_NAME   = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_DESTINATION = ENV["PKG_DESTINATION"] || "../#{PKG_NAME}"

RELEASE_NAME  = "REL #{PKG_VERSION}"

desc 'Default: run unit tests.'
task :default => 'test:units'

desc 'Test the library.'
task :test => ['test:units','test:integration','test:perf']

namespace :test do
  desc 'Unit tests'
  Rake::TestTask.new(:units) do |t|
    t.libs << 'lib'
    t.pattern = 'test/unit/**/*_test.rb'
    t.verbose = true
  end
  
  desc 'Integration tests'
  Rake::TestTask.new(:integration) do |t|
    t.libs << 'lib'
    t.pattern = 'test/integration/**/*_test.rb'
    t.verbose = true
  end
  
  desc 'Performance tests'
  Rake::TestTask.new(:perf) do |t|
    t.libs << 'lib'
    t.pattern = 'test/perf/**/*_test.rb'
    t.verbose = true
  end
end

desc 'Generate documentation for the library.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Document-based Ruby Database'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :rcov do
  namespace :test do
    desc 'Measures unit test coverage'
    task :unit do
      rm_f 'coverage.data'
      mkdir 'coverage' unless File.exist?('coverage')
      rcov = "rcov --aggregate coverage.data --text-summary -Ilib"
      system("#{rcov} test/unit/*_test.rb")
      #system("open coverage/index.html") if PLATFORM['darwin']
    end
  end
end

PKG_FILES = FileList[
  #'CHANGELOG',
  #'LICENSE',
  'README',
  #'TODO',
  'Rakefile',
  'bin/**/*',
  'doc/**/*',
  'lib/**/*',
  'example/**/*',
] - [ 'test' ]

spec = Gem::Specification.new do |s|
  s.name = 'rddb'
  s.version = PKG_VERSION
  s.summary = "Document-oriented Ruby Database."
  s.description = <<-EOF
    A documented-oriented Ruby database using Ruby code for views.
  EOF

  s.add_dependency('rake', '>= 0.7.1')
  s.add_dependency('mongrel', '>= 1.0.1')
  s.add_dependency('uuid', '>= 1.0.4')
  s.add_dependency('daemons', '>= 1.0.7')
  s.add_dependency('aws-s3', '>= 0.4.0')
  s.add_dependency('json', '>= 1.1.1')

  s.rdoc_options << '--exclude' << '.'
  s.has_rdoc = false

  s.files = PKG_FILES.to_a.delete_if {|f| f.include?('.svn')}
  s.require_path = 'lib'
  
  s.bindir = "bin" # Use these for applications.
  s.executables = ['rddb-server','rddb-worker']
  s.default_executable = "rddb-server"

  s.author = "Anthony Eden"
  s.email = "anthonyeden@gmail.com"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
  pkg.need_tar = true
  pkg.need_zip = true
end

desc "Generate code statistics"
task :lines do
  lines, codelines, total_lines, total_codelines = 0, 0, 0, 0

  for file_name in FileList["lib/**/*.rb"]
    next if file_name =~ /vendor/
    f = File.open(file_name)

    while line = f.gets
      lines += 1
      next if line =~ /^\s*$/
      next if line =~ /^\s*#/
      codelines += 1
    end
    puts "L: #{sprintf("%4d", lines)}, LOC #{sprintf("%4d", codelines)} | #{file_name}"
    
    total_lines     += lines
    total_codelines += codelines
    
    lines, codelines = 0, 0
  end

  puts "Total: Lines #{total_lines}, LOC #{total_codelines}"
end

desc "Reinstall the gem from a local package copy"
task :reinstall => [:package] do
  windows = RUBY_PLATFORM =~ /mswin/
  sudo = windows ? '' : 'sudo'
  gem = windows ? 'gem.bat' : 'gem'
  `#{sudo} #{gem} uninstall -x -i #{PKG_NAME}`
  `#{sudo} #{gem} install pkg/#{PKG_NAME}-#{PKG_VERSION}`
end