require File.join( File.expand_path( File.dirname( __FILE__ ) ), '../../', 'spec_helper' )

describe Arachni::RPC::Exceptions do

    describe "#rpc_connection_error?" do
        context "for ConnectionError" do
            subject { ::Arachni::RPC::Exceptions::ConnectionError.new.rpc_connection_error? }
            it { should be_true }
        end

        context "for other exceptions" do
            subject { ::Arachni::RPC::Exceptions::InvalidMethod.new.rpc_connection_error? }
            it { should be_false }
        end
    end

    describe "#rpc_remote_exception?" do
        context "for RemoteException" do
            subject { ::Arachni::RPC::Exceptions::RemoteException.new.rpc_remote_exception? }
            it { should be_true }
        end

        context "for other exceptions" do
            subject { ::Arachni::RPC::Exceptions::InvalidMethod.new.rpc_remote_exception? }
            it { should be_false }
        end
    end


    describe "#rpc_exception?" do
        context "for RPC exceptions" do
            subject { ::Arachni::RPC::Exceptions::InvalidMethod.new.rpc_exception? }
            it { should be_true }
        end

        context "for other exceptions" do
            subject { ::Exception.new.rpc_connection_error? }
            it { should be_false }
        end
    end

end
