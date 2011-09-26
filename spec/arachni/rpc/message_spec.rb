require File.join( File.expand_path( File.dirname( __FILE__ ) ), '../../', 'spec_helper' )

describe Arachni::RPC::Message do

    describe "#initialize" do
        it "should set class attribute values from param hash"
    end

    describe "#merge!" do
        it "should assign the attribute values of the provided object to the ones in self"
    end

    describe "#prepare_for_tx" do
        it "should convert self into a hash"
        it "should skip attributes based on #transmit? return value"
    end

end
