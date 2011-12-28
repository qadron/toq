=begin

    This file is part of the Arachni-RPC project and may be subject to
    redistribution and commercial restrictions. Please see the Arachni-RPC
    web site for more information on licensing and terms of use.

=end

require 'rubygems'

begin
    require 'rspec'
    require 'rspec/core/rake_task'

    RSpec::Core::RakeTask.new do |t|
      t.rspec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
    end
rescue
end

desc "Generate docs"

task :docs do

    outdir = "../arachni-rpc-pages"
    sh "mkdir #{outdir}" if !File.directory?( outdir )

    sh "yardoc --verbose --title \
      \"Arachni-RPC\" \
       lib/* -o #{outdir} \
      - CHANGELOG.md LICENSE.md"


    sh "rm -rf .yard*"
end


#
# Cleans reports and logs
#
desc "Cleaning..."
task :clean do
    sh "rm *.gem || true"
end



#
# Building
#
desc "Build the arachni-rpc gem."
task :build => [ :clean ] do
    sh "gem build arachni-rpc.gemspec"
end


#
# Installing
#
desc "Build and install the arachni gem."
task :install  => [ :build ] do

    require File.expand_path( File.dirname( __FILE__ ) ) + '/lib/arachni/rpc/version'

    sh "gem install arachni-rpc-#{Arachni::RPC::VERSION}.gem"
end


#
# Publishing
#
desc "Push a new version to Gemcutter"
task :publish => [ :build ] do

    require File.expand_path( File.dirname( __FILE__ ) ) + '/lib/arachni/rpc/version'

    sh "gem push arachni-rpc-#{Arachni::RPC::VERSION}.gem"
end
