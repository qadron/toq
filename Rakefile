=begin
                  Arachni
  Copyright (c) 2010-2011 Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>

  This is free software; you can copy and distribute and modify
  this program under the term of the GPL v2.0 License
  (See LICENSE file for details)

=end

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
# Simple profiler using perftools[1].
#
# To install perftools for Ruby:
#   gem install perftools.rb
#
# [1] https://github.com/tmm1/perftools.rb
#
desc "Profile Arachni"
task :profile do
    sh "CPUPROFILE_FREQUENCY=500 CPUPROFILE=/tmp/profile.dat " +
        "RUBYOPT=\"-r`gem which perftools | tail -1`\" " +
        " ./bin/arachni http://demo.testfire.net --link-count=5 && " +
        "pprof.rb --gif /tmp/profile.dat > profile.gif"
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

    require File.expand_path( File.dirname( __FILE__ ) ) + '/lib/arachni/rpc'

    sh "gem install arachni-rpc-#{Arachni::RPC::VERSION}.gem"
end


#
# Publishing
#
desc "Push a new version to Gemcutter"
task :publish => [ :build ] do

    require File.expand_path( File.dirname( __FILE__ ) ) + '/lib/arachni/rpc'

    sh "gem push arachni-rpc-#{Arachni::RPC::VERSION}.gem"
end
