require File.join( File.expand_path( File.dirname( __FILE__ ) ), '../../', 'spec_helper' )

class MyMessage < Arachni::RPC::Message
    attr_reader :foo
    attr_accessor :boo

    def transmit?( attr )
        attr == :@boo
    end

end

describe Arachni::RPC::Message do

    before( :all ) do
        @opts = { :foo => 'foo val', :boo => 'boo val' }
        @msg = MyMessage.new( @opts )
    end

    describe "#initialize" do
        it "should set class attribute values from param hash" do
            i = 0
            i += 1 if ( @msg.foo == @opts[:foo] )
            i += 1 if ( @msg.boo == @opts[:boo] )

            i.should == 2
        end
    end

    describe "#merge!" do
        it "should assign the attribute values of the provided object to the ones in self" do

            opts = { :foo => 'my foo', :callback_id => 2 }
            my_msg = MyMessage.new( opts )

            msg = MyMessage.new( @opts )
            msg.merge!( my_msg )

            i = 0
            i += 1 if ( msg.foo == opts[:foo] )
            i += 1 if ( msg.boo == @opts[:boo] )

            i.should == 2
        end
    end

    describe "#prepare_for_tx" do

        it "should convert self into a hash" do
            @msg.prepare_for_tx.class.should == Hash
        end

        it "should skip attributes based on #transmit? return value" do
            i = 0
            i += 1 if !@msg.prepare_for_tx['boo'].nil?
            i += 1 if @msg.prepare_for_tx['callback_id'].nil?
            i += 1 if @msg.prepare_for_tx['foo'].nil?

            i.should == 3
        end
    end

end
