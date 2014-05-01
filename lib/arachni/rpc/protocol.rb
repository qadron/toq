=begin

    This file is part of the Arachni-RPC project and may be subject to
    redistribution and commercial restrictions. Please see the Arachni-RPC EM
    web site for more information on licensing and terms of use.

=end

module Arachni
module RPC

# Provides helper transport methods for {Message} transmission.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
module Protocol

    # @param    [Message]    msg
    #   Message to send to the peer.
    def send_message( msg )
        send_object( msg.prepare_for_tx )
    end
    alias :send_request  :send_message
    alias :send_response :send_message

    # Receives data from the network.
    #
    # Rhe data will be chunks of a serialized object which will be buffered
    # until the whole transmission has finished.
    #
    # It will then unserialize it and pass it to {#receive_object}.
    def on_data( data )
        (@buf ||= '') << data

        while @buf.size >= 4
            if @buf.size >= 4 + ( size = @buf.unpack( 'N' ).first )
                @buf.slice!( 0, 4 )
                receive_object( unserialize( @buf.slice!( 0, size ) ) )
            else
                break
            end
        end
    end

    private

    # Stub method, should be implemented by servers.
    #
    # @param    [Request]     request
    # @abstract
    def receive_request( request )
        p request
    end

    # Stub method, should be implemented by clients.
    #
    # @param    [Response]    response
    # @abstract
    def receive_response( response )
        p response
    end

    # Converts incoming hash objects to {Request} and {Response} objects
    # (depending on the assumed role) and calls {#receive_request} or
    # {#receive_response} accordingly.
    #
    # @param    [Hash]      obj
    def receive_object( obj )
        if @role == :server
            receive_request( Request.new( obj ) )
        else
            receive_response( Response.new( obj ) )
        end
    end

    # @param    [Object]    obj
    #   Object to send.
    def send_object( obj )
        data = serialize( obj )
        send_data [data.bytesize, data].pack( 'Na*' )
    end

    # Returns the preferred serializer based on the `serializer` option of the
    # server.
    #
    # @return   [.load, .dump]
    #   Serializer to be used (Defaults to `YAML`).
    def serializer
        return @client_serializer if @client_serializer

        @opts[:serializer] ? @opts[:serializer] : YAML
    end

    def fallback_serializer
        @opts[:fallback_serializer] ? @opts[:serializer] : YAML
    end

    def serialize( obj )
        serializer.dump obj
    end

    def unserialize( obj )
        serializer.load( obj )
    end

end

end
end
