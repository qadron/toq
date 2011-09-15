=begin
                  Arachni-RPC
  Copyright (c) 2011 Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>

  This is free software; you can copy and distribute and modify
  this program under the term of the GPL v2.0 License
  (See LICENSE file for details)

=end

require File.join( File.expand_path( File.dirname( __FILE__ ) ), '../', 'rpc' )

module Arachni
module RPC

#
# EventMachine-based RPC server class.
#
# It's capable of:
# - performing and handling a few thousands requests per second (depending on call size, network conditions and the like)
# - TLS encrytion
# - asynchronous and synchronous requests
# - handling asynchronous methods that require a block
#
# @author: Tasos "Zapotek" Laskos
#                                      <tasos.laskos@gmail.com>
#                                      <zapotek@segfault.gr>
# @version: 0.1
#
class Server

    include ::Arachni::RPC::Exceptions

    #
    # Handles EventMachine's connection stuff.
    #
    # It's responsible for TLS, serializing, transmitting and receiving objects,
    # as well as authenticating the client using the token.
    #
    # It also handles and forwards exceptions.
    #
    # @author: Tasos "Zapotek" Laskos
    #                                      <tasos.laskos@gmail.com>
    #                                      <zapotek@segfault.gr>
    # @version: 0.1
    #
    class Proxy < EventMachine::Connection

        include ::EM::P::ObjectProtocol
        include ::Arachni::RPC::Exceptions

        def initialize( server )
            super
            @server = server
            @server.proxy = self
        end

        # starts TLS
        def post_init
            start_tls
        end

        #
        # Pretty much does all the work.
        #
        # The request should look like:
        #
        #    {
        #        'call'  => msg, # RPC message in the form of 'handler.method'
        #        'args'  => args, # optional array of arguments for the remote method
        #        'token' => token, # optional authentication token,
        #
        #        # unique identifier for the callback, completely irrelevant to the server.
        #        # it's passed right back to the client along with the result of the call.
        #        'cb_id' => callback_id
        #    }
        #
        #
        # @param    [Hash]      req     request hash
        #
        def receive_object( req )

            # the method call may block a little so tell EventMachine to
            # stick it in its own thread.
            ::EM.defer( proc {
                begin
                    peer = peer_ip_addr

                    # token-based authentication
                    authenticate!( peer, req )

                    # grab the result of the method call
                    obj = @server.call( peer, req )

                # handle exceptions and convert them to a simple hash,
                # ready to be passed to the client.
                rescue Exception => e
                    obj = {
                        'exception' => e.to_s,
                        'backtrace' => e.backtrace,
                        'type'      => e.class.name.split( ':' )[-1]
                    }

                    msg = "#{e.to_s}\n#{e.backtrace.join( "\n" )}"
                    @server.logger.error( 'Exception' ){ msg + " [on behalf of #{peer}]" }
                end

                obj
            }, proc { |obj|
                # pass the result of the RPC call back to the client
                # along with the callback ID
                send_object( { 'obj' => obj, 'cb_id' => req['cb_id'] } )
            })
        end

        #
        # @return   [String]    IP address of the client
        #
        def peer_ip_addr
            Socket.unpack_sockaddr_in( get_peername )[1]
        end

        #
        # Authenticates the client based on the token in the request.
        #
        # It will raise an exception if the token doesn't check-out.
        #
        # @param    [String]    peer    IP address of the client
        # @oaram    [Hash]      req     request
        #
        def authenticate!( peer, req )
            if !valid_token?( req['token'] )
                msg = 'Token missing or invalid while calling: ' +
                    req['call']
                @server.logger.error( 'Authenticator' ){ msg + " [on behalf of #{peer}]" }
                raise( InvalidToken.new( msg ) )
            end
        end

        #
        # Compares the authentication token in the param with the one of the server.
        #
        # @param    [String]    token
        #
        # @return   [Bool]
        #
        def valid_token?( token )
            return true if token == @server.token
            return false
        end

        #
        # Returns the prefered serializer based on the 'serializer' option of the server.
        #
        # Defaults to <i>YAML</i>.
        #
        # @return   [Class]     serializer to be used
        #
        # @see http://eventmachine.rubyforge.org/EventMachine/Protocols/ObjectProtocol.html#M000369
        #
        def serializer
            @server.opts[:serializer] ? @server.opts[:serializer] : YAML
        end

    end

    attr_reader :token
    attr_reader :opts
    attr_reader :logger
    attr_writer :proxy

    def initialize( opts )
        @opts  = opts
        @token = @opts[:token]

        @logger = ::Logger.new( STDOUT )
        @logger.level = Logger::INFO

        @host, @port = @opts[:host], @opts[:port]

        clear_handlers
    end

    def add_async_check( &block )
        @async_checks << block
    end

    def add_handler( name, obj )
        @objects[name] = obj
        @methods[name] = Set.new # no lookup overhead please :)
        @async_methods[name] = Set.new

        obj.class.public_instance_methods( false ).each {
            |method|
            @methods[name] << method.to_s
            @async_methods[name] << method.to_s if async_check( obj.method( method ) )
        }
    end

    def clear_handlers
        @objects = {}
        @methods = {}

        @async_checks  = []
        @async_methods = {}
    end

    def run
        @logger.info( 'System' ){ "RPC Server started." }
        @logger.info( 'System' ){ "Listening on #{@host}:#{@port}" }
        Arachni::RPC::EM.add_to_reactor {
            ::EM.start_server( @host, @port, Proxy, self )
        }
        Arachni::RPC::EM.block!
    end

    def call( peer_ip_addr, req )

        expr, args = req['call'], req['args']
        meth_name, obj_name = parse_expr( expr )

        log_call( peer_ip_addr, expr, *args )

        if !object_exist?( obj_name )
            msg = "Trying to access non-existent object '#{obj_name}'."
            @logger.error( 'Call' ){ msg + " [on behalf of #{peer_ip_addr}]" }
            raise( InvalidObject.new( msg ) )
        end

        if !public_method?( obj_name, meth_name )
            msg = "Trying to access non-public method '#{meth_name}'."
            @logger.error( 'Call' ){ msg + " [on behalf of #{peer_ip_addr}]" }
            raise( InvalidMethod.new( msg ) )
        end

        if !is_async?( obj_name, meth_name )
            @objects[obj_name].send( meth_name.to_sym, *args )
        else
            @objects[obj_name].send( meth_name.to_sym, *args ){
                |obj|
                @proxy.send_object( { 'obj' => obj, 'cb_id' => req['cb_id'] } )
            }
        end
    end

    def alive?
        return true
    end

    def shutdown
        wait_for = 5

        @logger.info( 'System' ){ "Shutting down in #{wait_for} seconds..." }

        # don't die before returning
        EventMachine::add_timer( wait_for ) { ::EM.stop }
        return true
    end

    private

    def is_async?( objname, method )
        @async_methods[objname].include?( method )
    end

    def async_check( method )
        @async_checks.each {
            |check|
            return true if check.call( method )
        }
        return false
    end


    def log_call( peer_ip_addr, expr, *args )
        msg = "#{expr}"

        # this should be in a @logger.debug call but it'll get out of sync
        if @logger.level == Logger::DEBUG
            cargs = args.map { |arg| arg.inspect }
            msg += "( #{cargs.join( ', ' )} )"
        end

        msg += " [#{peer_ip_addr}]"

        @logger.info( 'Call' ){ msg }
    end

    def parse_expr( expr )
        parts = expr.to_s.split( '.' )

        # method name, object name
        [ parts.pop, parts.join( '.' ) ]
    end

    def object_exist?( obj_name )
        @objects[obj_name] ? true : false
    end

    def public_method?( obj_name, method )
        @methods[obj_name].include?( method )
    end

end

end
end
