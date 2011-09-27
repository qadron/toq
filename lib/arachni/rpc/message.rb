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
# Represents an RPC message, serves as the basis for {Request} and {Response}.
#
# @author: Tasos "Zapotek" Laskos
#                                      <tasos.laskos@gmail.com>
#                                      <zapotek@segfault.gr>
# @version: 0.1
#
class Message

    #
    # Unique identifier for the callback.
    #
    # @return   [String]
    #
    attr_accessor :callback_id


    #
    # @param    [Hash]   opts   sets instance attributes
    #
    def initialize( opts = {} )
        opts.each_pair {
            |k, v|
            instance_variable_set( "@#{k}".to_sym, v )
        }
    end

    #
    # Merges the attributes of another message with self.
    #
    # (The param doesn't *really* have to be a message, any object will do.)
    #
    # @param    [Message]   message
    #
    def merge!( message )
        message.instance_variables.each {
            |var|
            val = message.instance_variable_get( var )
            instance_variable_set( var, val )
        }
    end

    #
    # Prepares the message for transmition (i.e. converts the message to a Hash).
    #
    # Attributes that should not be included can be skipped by implementing
    # {#transmit?} and returning the appropriate value.
    #
    # @return   [Hash]
    #
    def prepare_for_tx
        hash = {}
        instance_variables.each {
            |k|
            next if !transmit?( k )
            hash[normalize( k )] = instance_variable_get( k )
        }
        return hash
    end

    #
    # Decides which attributes should be skipped by {#prepare_for_tx}.
    #
    # @param    [Symbol]    attr    attribute symbol (i.e. :@token)
    #
    def transmit?( attr )
        return true
    end

    private

    def normalize( attr )
        attr.to_s.gsub( '@', '' )
    end

end

end
end