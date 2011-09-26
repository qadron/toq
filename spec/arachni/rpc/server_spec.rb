require File.join( File.expand_path( File.dirname( __FILE__ ) ), '../../', 'spec_helper' )

class Arachni::RPC::Server
    public :is_async?, :async_check, :object_exist?, :public_method?
end

describe Arachni::RPC::Server do

    before( :all ) do
        @server = Arachni::RPC::Server.new(
            :host  => 'localhost',
            :port  => 7331,
            :token => 'superdupersecret',
            :serializer => Marshal,

            # :ssl_ca     => cwd + '/pems/cacert.pem',
            # :ssl_pkey   => cwd + '/pems/server/key.pem',
            # :ssl_cert   => cwd + '/pems/server/cert.pem'
        )
    end

    describe "#initialize" do
        it "should be able to properly setup class options"
    end

    it "should retain the supplied token"
    it "should have a Logger"

    describe "#shutdown!" do
        it "should stop the server"
    end

    describe "#alive?" do
        subject { @server.alive? }
        it { should == true }
    end

    describe "#is_async?" do
        it "should return true for async methods"
        it "should return false for sync methods"
    end

    describe "#async_check" do
        it "should return true for async methods"
        it "should return false for sync methods"
    end

    describe "#object_exist?" do
        it "should return true for valid objects"
        it "should return false for inexistent objects"
    end

    describe "#public_method?" do
        it "should return true for public methods"
        it "should return false for inexistent or non-public methods"
    end

    describe Arachni::RPC::Server::Proxy do

        describe "#valid_token?" do
            it "should return true on valid token"
            it "should return false on invalid token"
        end

        describe "#authenticate!" do
            it "should return true on valid token"
            it "should throw exception on invalid token"
        end

        describe "#serializer" do
            it "should have a default value"
            it "should return the supplied value"
        end
    end

end

