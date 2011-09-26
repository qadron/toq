require File.join( File.expand_path( File.dirname( __FILE__ ) ), '../../', 'spec_helper' )

describe Arachni::RPC::SSL do

    describe "#ca_store" do
        it "should return an OpenSSL::X509::Store"
    end

    describe "#ssl_verify_peer" do
        it "should return true on valid peer cert"
        it "should return false on invalid peer cert"
    end

    describe "#are_we_a_client?" do

        context "when run from inside a client" do
            it "should return true"
        end

        context "when run from inside a server" do
            it "should return false"
        end

    end

    describe "#ssl_opts?" do
        context "when all SSL opts have been provided" do
            it "should return true"
        end

        context "when not all SSL opts have been provided" do
            it "should return false"
        end
    end

end
