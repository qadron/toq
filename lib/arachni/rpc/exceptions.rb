=begin
                  Arachni-RPC
  Copyright (c) 2011 Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>

  This is free software; you can copy and distribute and modify
  this program under the term of the GPL v2.0 License
  (See LICENSE file for details)

=end

#
# Adds helper methods to all objects to make identifying RPC Exceptions easier.
#
class Object

    #
    # @return   [Bool]  true if self is a connection error exception
    #                       ({::Arachni::RPC::Exceptions::ConnectionError})
    #
    def rpc_connection_error?
        false
    end

    #
    # @return   [Bool]  true if self represents a remote exception
    #                       ({::Arachni::RPC::Exceptions::RemoteException})
    #
    def rpc_remote_exception?
        false
    end

    #
    # @return   [Bool]  true if self represents an invalid object exception
    #                       ({::Arachni::RPC::Exceptions::InvalidMethod})
    #
    def rpc_invalid_object_error?
        false
    end

    #
    # @return   [Bool]  true if self represents an invalid method exception
    #                       ({::Arachni::RPC::Exceptions::InvalidMethod})
    #
    def rpc_invalid_method_error?
        false
    end

    #
    # @return   [Bool]  true if self represents an invalid token exception
    #                       ({::Arachni::RPC::Exceptions::InvalidToken})
    #
    def rpc_invalid_token_error?
        false
    end

    #
    # @return   [Bool]  true if self is any sort of RPC exception ({::Arachni::RPC::Exceptions})
    #
    def rpc_exception?
        false
    end

end

module Arachni
module RPC
module Exceptions

    class Base < ::Exception
        #
        # @return   [Bool]  true
        #
        def rpc_exception?
            true
        end
    end

    #
    # Signifies an abruptly terminated connection.
    #
    # Look for network or SSL errors or a dead server or a mistyped server address/port.
    #
    class ConnectionError < Base

        #
        # @return   [Bool]  true
        #
        def rpc_connection_error?
            true
        end
    end

    #
    # Signifies an exception that occured on the server-side.
    #
    # Look errors on the remote method and review the server output for more details.
    #
    class RemoteException < Base

        #
        # @return   [Bool]  true
        #
        def rpc_remote_exception?
            true
        end
    end

    #
    # An invalid object has been called.
    #
    # Make sure that there is a server-side handler for the object you called.
    #
    class InvalidObject < Base

        #
        # @return   [Bool]  true
        #
        def rpc_invalid_object_error?
            true
        end

    end

    #
    # An invalid method has been called.
    #
    # Occurs when a remote method doesn't exist or isn't public.
    #
    class InvalidMethod < Base

        #
        # @return   [Bool]  true
        #
        def rpc_invalid_method_error?
            true
        end

    end

    #
    # Signifies an authentication token mismatch between the client and the server.
    #
    class InvalidToken  < Base

        #
        # @return   [Bool]  true
        #
        def rpc_invalid_token_error?
            true
        end

    end
end
end
end
