=begin
                  Arachni-RPC
  Copyright (c) 2011 Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>

  This is free software; you can copy and distribute and modify
  this program under the term of the GPL v2.0 License
  (See LICENSE file for details)

=end

module Arachni
module RPC
module Exceptions
    class ConnectionError < ::Exception; end
    class RemoteException < ::Exception; end
    class InvalidObject < ::Exception; end
    class InvalidMethod < ::Exception; end
    class InvalidToken  < ::Exception; end
end
end
end

#
# Adds helper methods to all objects to make identifying RPC Exceptions easier.
#
class Object

    #
    # @return   [Bool]  true if self is a connection error exception
    #                       ({::Arachni::RPC::Exceptions::ConnectionError})
    #
    def rpc_connection_error?
        self.class == ::Arachni::RPC::Exceptions::ConnectionError
    end

    #
    # @return   [Bool]  true if self represents a remote exception
    #                       ({::Arachni::RPC::Exceptions::RemoteException})
    #
    def rpc_remote_exception?
        self.class == ::Arachni::RPC::Exceptions::RemoteException
    end

    #
    # @return   [Bool]  true if self is any sort of RPC exception ({::Arachni::RPC::Exceptions})
    #
    def rpc_exception?
        name = self.class.name.split( '::' )[-1]
        ::Arachni::RPC::Exceptions.constants.include?( name.to_sym )
    end

end
