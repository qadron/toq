=begin

    This file is part of the Toq project and may be subject to
    redistribution and commercial restrictions. Please see the Toq
    web site for more information on licensing and terms of use.

=end

require_relative 'message'

module Toq

# Represents an RPC request.
#
# It's here only for formalization purposes, it's not actually sent over the wire.
#
# What is sent is a hash generated by {#prepare_for_tx}. which is in the form of:
#
#
#     {
#         # RPC message in the form of 'handler.method'.
#         'message' => msg,
#         # Optional array of arguments for the remote method.
#         'args'    => args,
#         # Optional authentication token.
#         'token'   => token
#     }
#
# Any client that has SSL support and can serialize a Hash just like the one
# above can communicate with the RPC server.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@arachni-scanner.com>
class Request < Message

    # @return   [String]
    #   RPC message in the form of 'handler.method'.
    attr_accessor :message

    # @return   [Array]
    #   Optional arguments for the remote method.
    attr_accessor :args

    # @return   [String]
    #   Optional authentication token.
    attr_accessor :token

    # @return   [Proc]
    #   Callback to be invoked on the response.
    attr_accessor :callback

    private

    def transmit?( attr )
        ![ :@callback ].include?( attr )
    end

end

end
