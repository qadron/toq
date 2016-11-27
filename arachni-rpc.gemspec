=begin

    This file is part of the Arachni-RPC project and may be subject to
    redistribution and commercial restrictions. Please see the Arachni-RPC
    web site for more information on licensing and terms of use.

=end

Gem::Specification.new do |s|
      require File.expand_path( File.dirname( __FILE__ ) ) + '/lib/arachni/rpc/version'

      s.name              = 'arachni-rpc'
      s.version           = Arachni::RPC::VERSION
      s.date              = Time.now.strftime('%Y-%m-%d')
      s.summary           = 'The RPC protocol of the Arachni Framework.'
      s.homepage          = 'https://github.com/Arachni/arachni-rpc'
      s.email             = 'tasos.laskos@arachni-scanner.com'
      s.authors           = [ 'Tasos Laskos' ]

      s.files             = %w(README.md Rakefile LICENSE.md CHANGELOG.md)
      s.files            += Dir.glob('lib/**/**')
      s.test_files        = Dir.glob('spec/**/**')

      s.extra_rdoc_files  = %w(README.md LICENSE.md CHANGELOG.md)
      s.rdoc_options      = ['--charset=UTF-8']

      s.add_dependency 'arachni-reactor', '~> 0.1.2'

      s.description = <<description
        Arachni::RPC is a simple and lightweight Remote Procedure Call protocol
        used to provide the basis for Arachni's distributed infrastructure.
description
end
