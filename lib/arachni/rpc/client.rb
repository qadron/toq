=begin
                  Arachni-RPC
  Copyright (c) 2011 Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>

  This is free software; you can copy and distribute and modify
  this program under the term of the GPL v2.0 License
  (See LICENSE file for details)

=end

require File.join( File.expand_path( File.dirname( __FILE__ ) ), '../', 'rpc' )
require 'ap'

module Arachni
module RPC

#
# Simple EventMachine-based RPC client.
#
# It's capable of:
# - performing and handling a few thousands requests per second (depending on call size, network conditions and the like)
# - TLS encrytion
# - asynchronous and synchronous requests
# - handling remote asynchronous calls that require a block
#
# @author: Tasos "Zapotek" Laskos
#                                      <tasos.laskos@gmail.com>
#                                      <zapotek@segfault.gr>
# @version: 0.1
#
class Client

    include ::Arachni::RPC::Exceptions

    #
    # Maps the methods of remote objects to local ones.
    # (Well, not really, it just passes the message along to the remote end.)
    #
    # You start like:
    #
    #    server = Arachni::RPC::Client.new( :host => 'localhost', :port => 7331 )
    #    bench  = Arachni::RPC::Client::Mapper.new( server, 'bench' )
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
    #    server = Arachni::RPC::Server.new( :host => 'localhost', :port => 7331 )
    #    server.add_handler( 'bench', Bench.new )
    #
    # @author: Tasos "Zapotek" Laskos
    #                                      <tasos.laskos@gmail.com>
    #                                      <zapotek@segfault.gr>
    # @version: 0.1
    #
    class Mapper

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

    #
    # Handles EventMachine's connection and RPC related stuff.
    #
    # It's responsible for TLS, storing and calling callbacks as well as
    # serializing, transmitting and receiving objects.
    #
    # @author: Tasos "Zapotek" Laskos
    #                                      <tasos.laskos@gmail.com>
    #                                      <zapotek@segfault.gr>
    # @version: 0.1
    #
    class Handler < EventMachine::Connection
        include ::EM::P::ObjectProtocol

        attr_reader :callbacks

        def initialize( server )
            @server = server

            @do_not_defer = Set.new
        end

        def post_init
            start_tls
            @callbacks_mutex = Mutex.new
            @callbacks = {}
        end

        #
        # Used to handle received objects.
        #
        # The res hash should look something like:
        #
        #    {
        #        'obj'   => object, # response to the RPC request
        #        'cb_id' => callback_id # the callback ID as specified in the request
        #    }
        #
        # @param    [Hash]    res   server response object
        #
        def receive_object( res )

            if exception?( res )
                res['obj'] = exception( res['obj'] )
            end

            if cb = get_callback( res )

                if defer?( res['cb_id'] )
                    # the callback might block a bit so tell EM to put it in a thread
                    ::EM.defer {
                        cb.call( res['obj'] )
                    }
                else
                    cb.call( res['obj'] )
                end
            end
        end

        def exception?( res )
            res['obj'].is_a?( Hash ) && res['obj']['exception'] ? true : false
        end

        def exception( obj )
            klass = Arachni::RPC::Exceptions.const_get( obj['type'].to_sym )
            e = klass.new( obj['exception'] )
            e.set_backtrace( obj['backtrace'] )
            return e
        end

        #
        # Sets a callback and sends the request.
        #
        # The request should look like:
        #
        #    {
        #        'call'  => msg, # RPC message in the form of 'handler.method'
        #        'args'  => args, # optional array of arguments for the remote method
        #        'token' => token, # optional authentication token,
        #        'cb_id' => callback_id # unique identifier for the callback,
        #        'cb'    => callback to be invoked on the response
        #    }
        #
        #
        # @param    [Hash]      req     request hash
        #
        def set_callback_and_send( req )
            cb = req.delete( 'cb' )

            do_not_defer = req.delete( 'do_not_defer' ) ? true : false
            send_object( req.merge( 'cb_id' => set_callback( req, cb, do_not_defer ) ) )
        end

        def set_callback( obj, cb, do_not_defer )
            @callbacks_mutex.lock

            cb_id = obj.__id__.to_s + ':' + cb.__id__.to_s
            @callbacks[cb_id] ||= {}
            @callbacks[cb_id] = cb

            @do_not_defer << cb_id if do_not_defer

            return cb_id
        ensure
            @callbacks_mutex.unlock
        end

        def defer?( cb_id )
            !@do_not_defer.include?( cb_id )
        end

        def get_callback( obj )
            @callbacks_mutex.lock

            if @callbacks[obj['cb_id']] && cb = @callbacks.delete( obj['cb_id'] )
                return cb
            end

        ensure
            @callbacks_mutex.unlock
        end

        def serializer
            @server.opts[:serializer] ? @server.opts[:serializer] : YAML
        end
    end

    attr_reader :opts
    attr_reader :do_not_defer

    #
    # Starts EventMachine and connects to the remote server.
    #
    # opts example:
    #
    #    {
    #        :host  => 'localhost',
    #        :port  => 7331,
    #
    #        # optional authentication token, if it doesn't match the one
    #        # set on the server-side you'll be getting exceptions.
    #        :token => 'superdupersecret',
    #
    #        # optional serializer (defaults to YAML)
    #        # see the 'serializer' method at:
    #        # http://eventmachine.rubyforge.org/EventMachine/Protocols/ObjectProtocol.html#M000369
    #        :serializer => Marshal
    #    }
    #
    # @param    [Hash]  opts
    #
    def initialize( opts )

        begin
            @@cache ||= {}

            @opts  = opts
            @token = @opts[:token]

            @host, @port = @opts[:host], @opts[:port]
            @k = "#{@host}:#{@port}"

            @do_not_defer = Set.new

            ::Arachni::RPC::EM.add_to_reactor{
                @@cache[@k] = ::EM.connect( @host, @port, Handler, self )
            }
        rescue EventMachine::ConnectionError => e
            exc = ConnectionError.new( e.to_s + " for '#{@k}'." )
            exc.set_backtrace( e.backtrace )
            raise exc
        end
    end

    #
    # Calls a remote method and grabs the result.
    #
    # There are 2 ways to perform a call, async (non-blocking) and sync (blocking).
    #
    # To perform an async call you need to provide a block which will be passed
    # the return value once the method has finished executing.
    #
    #    server.call( 'handler.method', arg1, arg2 ){
    #        |res|
    #        do_stuff( res )
    #    }
    #
    #
    # To perform a sync (blocking) call do not pass a block, the value will be
    # returned as usual.
    #
    #    res = server.call( 'handler.method', arg1, arg2 )
    #
    # @param    [String]    msg     in the form of <i>handler.method</i>
    # @param    [Array]     args    collection of argumenta to be passed to the method
    # @param    [Proc]      &block
    #
    def call( msg, *args, &block )

        opts = {
            'call' => msg,
            'args' => args,
            'cb'   => block
        }

        if block_given?
            call_async( opts )
        else
            return call_sync( opts )
        end
    end

    private
    def call_async( opts, &block )
        conn = @@cache[@k]

        if !conn
            raise ConnectionError.new( "Can't perform call," +
                " no connection has been established for '#{@k}'." )
        end

        opts['cb'] = block if block_given?

        ::EM.defer {
            opts['token'] = @token
            conn.set_callback_and_send( opts )
        }
    end

    def call_sync( opts )

        ret = nil
        # if we're in the Reactor thread use s Fiber and if we're not
        # use a Thread
        if !::EM::reactor_thread?
            t   = Thread.current
            call_async( opts ) {
                |obj|
                t.wakeup
                ret = obj
            }
            sleep
        else
            # Fibers do not work across threads so don't defer the callback
            # once the Handler gets to it
            opts['do_not_defer'] = true

            f = Fiber.current
            call_async( opts ) {
                |obj|
                f.resume( obj )
            }

            begin
                ret = Fiber.yield
            rescue FiberError => e
                msg = e.to_s + "\n"
                msg += '(Consider wrapping your sync code in a' +
                    ' "::Arachni::RPC::EM::Synchrony.run" ' +
                    'block when your app is running inside the Reactor\'s thread)'

                raise( msg )
            end
        end

        raise ret if ret.is_a?( Exception )
        return ret
    end

end

end
end
