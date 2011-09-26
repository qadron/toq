require File.join( File.expand_path( File.dirname( __FILE__ ) ), '../../', 'spec_helper' )

describe Arachni::RPC::Client do

    describe "#initialize" do
        it "should be able to properly setup class options"
    end

    describe "raw interface" do
        context "when using Threads" do
            it "should be able to perform synchronous calls"
            it "should be able to perform asynchronous calls"
        end

        context "when run inside the Reactor loop" do
            it "should be able to perform synchronous calls"
            it "should be able to perform asynchronous calls"
        end
    end

    describe "Mapper interface" do
        it "should be able to properly forward calls"
    end

    describe "exception" do
        context 'when performing asynchronous calls' do
            it "should be returned when requesting inexistent objects"
            it "should be returned when requesting inexistent or non-public methods"
        end

        context 'when performing synchronous calls' do
            it "should be raised when requesting inexistent objects"
            it "should be raised when requesting inexistent or non-public methods"
        end
    end

    it "should be able to retain stability and consistency under heavy load"

    context "when using valid SSL primitives" do
        it "should be able to establish a connection"
    end

    context "when using invalid SSL primitives" do
        it "should not be able to establish a connection"
    end

end
