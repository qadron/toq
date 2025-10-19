=begin

    This file is part of the Toq project and may be subject to
    redistribution and commercial restrictions. Please see the Toq
    web site for more information on licensing and terms of use.

=end

Gem::Specification.new do |s|
      require File.expand_path( File.dirname( __FILE__ ) ) + '/lib/toq/version'

      s.name              = 'toq'
      s.version           = Toq::VERSION
      s.license           = 'MPL v2'
      s.date              = Time.now.strftime('%Y-%m-%d')
      s.summary           = 'Simple RPC protocol.'
      s.homepage          = 'https://github.com/qadron/toq'
      s.email             = 'tasos.laskos@gmail.com'
      s.authors           = [ 'Tasos Laskos' ]

      s.files             = %w(README.md Rakefile LICENSE.md CHANGELOG.md)
      s.files            += Dir.glob('lib/**/**')
      s.test_files        = Dir.glob('spec/**/**')

      s.extra_rdoc_files  = %w(README.md LICENSE.md CHANGELOG.md)
      s.rdoc_options      = ['--charset=UTF-8']

      s.add_dependency 'raktr', '~> 0.0.1'

      s.description = <<description
        Toq is a simple and lightweight Remote Procedure Call protocol
        used to provide the basis for Arachni's distributed infrastructure.
description
end
