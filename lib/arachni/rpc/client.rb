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
        include ::Arachni::RPC::ConnectionUtilities

        include ::Arachni::RPC::SSL

        attr_reader :callbacks

        def initialize( opts )
            @opts = opts
            @status = :idle
        end

        def post_init
            @status = :active

            start_ssl

            @do_not_defer = Set.new
            @callbacks_mutex = Mutex.new
            @callbacks = {}
        end

        def unbind
            @status = :closed

            end_ssl

            e = Arachni::RPC::Exceptions::ConnectionError.new( 'Connection closed' )

            @callbacks_mutex.synchronize {
                if !(cb_keys = @callbacks.keys).empty?
                    cb_keys.each {
                        |k|
                        begin
                            @callbacks.delete( k ).call( e )
                        rescue
                        end
                    }
                end
            }
        end

        def status
            @status
        end

        #
        # Used to handle received objects.
        #
        # @param    [Hash]    res   server response object ({Response})
        #
        def receive_object( res )
            if exception?( res )
                res['obj'] = exception( res['obj'] )
            end

            if cb = get_callback( res )

                if defer?( res['callback_id'] )
                    # the callback might block a bit so tell EM to put it in a thread
                    ::EM.defer {
                        cb.call( res['obj'] )
                    }
                else
                    cb.call( res['obj'] )
                end
            end
        end

        # @param    [Hash]    res   server response object ({Response})
        def exception?( res )
            res['obj'].is_a?( Hash ) && res['obj']['exception'] ? true : false
        end

        #
        # Returns an exception based on the return object data.
        #
        def exception( obj )
            klass = Arachni::RPC::Exceptions.const_get( obj['type'].to_sym )
            e = klass.new( obj['exception'] )
            e.set_backtrace( obj['backtrace'] )
            return e
        end

        #
        # Sets a callback and sends the request.
        #
        # @param    [Arachni::RPC::Request]      req     request
        #
        def set_callback_and_send( req )
            req_h = req.prepare_for_tx

            cb_id = set_callback( req_h, req.callback, !req.defer? )
            req_h.merge!( 'callback_id' => cb_id )
            send_object( req_h )
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

            if @callbacks[obj['callback_id']] &&
               cb = @callbacks.delete( obj['callback_id'] )
                return cb
            end

        ensure
            @callbacks_mutex.unlock
        end

        def serializer
            @opts[:serializer] ? @opts[:serializer] : YAML
        end
    end

    #
    # Options hash
    #
    # @return   [Hash]
    #
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
    #        :serializer => Marshal,
    #
    #        #
    #        # Connection keep alive is set to true by default, this means that
    #        # a single connection will be maintained and all calls will pass
    #        # through it.
    #        # This bypasses a bug in EventMachine and allows you to perform thousands
    #        # of calls without issue.
    #        #
    #        # However, you are responsible for closing the connection when you're done.
    #        #
    #        # If keep alive is set to false then each call will go through its own connection
    #        # and the responsibility for closing that connection falls on Arachni-RPC.
    #        #
    #        # Unfortunately, if you try to make a greater number of calls than your system's
    #        # maximum open file descriptors limit EventMachine will freak-out.
    #        #
    #        :keep_alive => false,
    #
    #        #
    #        # In order to enable peer verification one must first provide
    #        # the following:
    #        #
    #        # SSL CA certificate
    #        :ssl_ca     => cwd + '/../spec/pems/cacert.pem',
    #        # SSL private key
    #        :ssl_pkey   => cwd + '/../spec/pems/client/key.pem',
    #        # SSL certificate
    #        :ssl_cert   => cwd + '/../spec/pems/client/cert.pem'
    #    }
    #
    # @param    [Hash]  opts
    #
    def initialize( opts )

        begin
            @opts  = opts.merge( :role => :client )
            @token = @opts[:token]

            @opts[:keep_alive]  = keep_alive?

            @host, @port = @opts[:host], @opts[:port]
            @do_not_defer = Set.new

            @conn = nil

            Arachni::RPC::EM.ensure_em_running!
        rescue EventMachine::ConnectionError => e
            exc = ConnectionError.new( e.to_s + " for '#{@k}'." )
            exc.set_backtrace( e.backtrace )
            raise exc
        end
    end

    #
    # Closes the connection and releases system resources.
    #
    # Don't forget to close the connection after you're done with it,
    # otherwise precious memory won't be reclaimed.
    #
    def close
        @conn.close_connection if @conn
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

        req = Request.new(
            :message  => msg,
            :args     => args,
            :callback => block,
            :token    => @token
        )

        if block_given?
            call_async( req )
        else
            return call_sync( req )
        end
    end

    private

    def connect
        ::EM.connect( @host, @port, Handler, @opts )
    end

    def cleanup!
        cnt = 0
        ObjectSpace.each_object( Arachni::RPC::Client::Handler ) {
            |obj|
            if obj.status == :active && obj.callbacks.empty?
                obj.close_connection
                cnt += 1
            end
        }
        return cnt
    end

    def call_async( req, &block )

        callback = nil

        if !keep_alive?
            @conn = connect
        elsif !( @conn ||= connect )
            raise ConnectionError.new( "Can't perform call," +
                " no connection has been established for '#{@host}:#{@port}'." )
        end

        req.callback = block if block_given?

        ::EM.schedule {
            @conn.set_callback_and_send( req )
            cleanup! if !keep_alive?
        }
    end

    def call_sync( req )

        ret = nil
        # if we're in the Reactor thread use s Fiber and if we're not
        # use a Thread
        if !::EM::reactor_thread?
            t   = Thread.current
            call_async( req ) {
                |obj|
                t.wakeup
                ret = obj
            }
            sleep
        else
            # Fibers do not work across threads so don't defer the callback
            # once the Handler gets to it
            req.do_not_defer!

            f = Fiber.current
            call_async( req ) {
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

    def keep_alive?
        @opts[:keep_alive].nil? ? true : @opts[:keep_alive] == true
    end

end

end
end
