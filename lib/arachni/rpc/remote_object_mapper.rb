=begin

    This file is part of the Arachni-RPC project and may be subject to
    redistribution and commercial restrictions. Please see the Arachni-RPC
    web site for more information on licensing and terms of use.

=end

require File.join( File.expand_path( File.dirname( __FILE__ ) ), '../', 'rpc' )

module Arachni
module RPC

#
# Maps the methods of remote objects to local ones.
# (Well, not really, it just passes the message along to the remote end.)
#
# You start like:
#
#    server = Arachni::RPC::EM::Client.new( :host => 'localhost', :port => 7331 )
#    bench  = Arachni::RPC::EM::Client::Mapper.new( server, 'bench' )
#
# And it allows you to do this:
#
#    res = bench.foo( 1, 2, 3 )
#
# Instead of:
#
#    res = client.call( 'bench.foo', 1, 2, 3 )
#
#
#
# The server on the other end must have an appropriate handler set, like:
#
#    class Bench
#        def foo( i = 0 )
#            return i
#        end
#    end
#
#    server = Arachni::RPC::EM::Server.new( :host => 'localhost', :port => 7331 )
#    server.add_handler( 'bench', Bench.new )
#
# @author: Tasos "Zapotek" Laskos
#                                      <tasos.laskos@gmail.com>
#                                      <zapotek@segfault.gr>
# @version: 0.1
#
class RemoteObjectMapper

    def initialize( server, remote )
        @server = server
        @remote = remote
    end

    private
    #
    # Used to provide the illusion of locality for remote methods
    #
    def method_missing( sym, *args, &block )
        call = "#{@remote}.#{sym.to_s}"
        @server.call( call, *args, &block )
    end

end

end
end
