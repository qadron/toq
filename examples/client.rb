=begin
                  Arachni-RPC
  Copyright (c) 2011 Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>

  This is free software; you can copy and distribute and modify
  this program under the term of the GPL v2.0 License
  (See LICENSE file for details)

=end

cwd = File.expand_path( File.dirname( __FILE__ ) )
require File.join( cwd, '../lib/arachni/', 'rpc' )


# connect to the server
client = Arachni::RPC::Client.new(
    :host  => 'localhost',
    :port  => 7331,

    # optional authentication token, if it doesn't match the one
    # set on the server-side you'll be getting exceptions.
    :token => 'superdupersecret',

    # optional serializer (defaults to YAML)
    # see the 'serializer' method at:
    # http://eventmachine.rubyforge.org/EventMachine/Protocols/ObjectProtocol.html#M000369
    :serializer => Marshal,

    # :ssl_ca     => cwd + '/../spec/pems/cacert.pem',
    # :ssl_pkey   => cwd + '/../spec/pems/client/key.pem',
    # :ssl_cert   => cwd + '/../spec/pems/client/cert.pem'
)

# Make things easy on the eyes using the mapper, it allows you to do this:
#
#    res = bench.foo( arg )
#
# Instead of:
#
#    res = client.call( 'bench.foo', arg )
#
bench = Arachni::RPC::Client::Mapper.new( client, 'bench' )

#
# In order to perform an asynchronous call you will need to provide a block,
# even if it is an empty one.
#
bench.foo( 'This is an async call to "bench.foo".' ) {
    |res|
    p res
    # => "This is an async call to \"bench.foo\"."
}


#
# On the server-side this is an async method but works just like everything else here.
#
# You'll need to kind-of specify the async methods on the server-side,
# check the server example file for more info.
#
bench.async_foo( 'This is an async call to "bench.async_foo".' ) {
    |res|
    p res
    # => "This is an async call to \"bench.async_foo\"."
}

p bench.async_foo( 'This is a sync call to "bench.async_foo".' )
# => "This is a sync call to \"bench.async_foo\"."


#
# To perform a sync (blocking) call do the usual stuff.
#
# This is thread safe so if you'd rather use Threads instead of async calls
# for that extra performance kick you go ahead and do your thing now...
#
p bench.foo( 'This is a sync call to "bench.foo".' )
# => "This is a sync call to \"bench.foo\"."


#
# When you are performing a synchronous call and things go wrong
# an exception will be thrown.
#
# Exceptions on the server-side unrelated to the RPC system will be forwarded.
#

#
# Non-existent object.
#
blah = Arachni::RPC::Client::Mapper.new( client, 'blah' )
begin
    p blah.something
rescue Exception => e
    p e  # => #<Arachni::RPC::Exceptions::InvalidObject: Trying to access non-existent object 'blah'.>
end

#
# Non-existent or non-public method.
#
begin
    p bench.fdoo
rescue Exception => e
    p e # => #<Arachni::RPC::Exceptions::InvalidMethod: Trying to access non-public method 'fdoo'.>
end

#
# When you are performing an asynchronous call and things go wrong
# an exception will be returned.
#
# It will *NOT* be thrown!
# It will be *RETURNED*!
#
blah.something {
    |res|
    p res # => #<Arachni::RPC::Exceptions::InvalidObject: Trying to access non-existent object 'blah'.>
}

#
# We don't know when async calls will return so we wait forever.
#
# Call ::EM.stop to break-out.
#
Arachni::RPC::EM.block!

