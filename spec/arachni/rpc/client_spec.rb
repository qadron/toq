require 'spec_helper'

describe Arachni::RPC::Client do

    def wait
        Arachni::Reactor.global.wait rescue Arachni::Reactor::Error::NotRunning
    end

    before(:each) do
        if Arachni::Reactor.global.running?
            Arachni::Reactor.stop
        end

        Arachni::Reactor.global.run_in_thread
    end

    before(:all) do
        @arg = [ 'one', 2,
            { :three => 3 }, [ 4 ]
        ]
    end

    it 'retains stability and consistency under heavy load' do
        client = start_client( rpc_opts )

        n   = 10_000
        cnt = 0

        mismatches = []

        n.times do |i|
            arg = 'a' * i
            client.call( 'test.foo', arg ) do |res|
                cnt += 1
                mismatches << [i, arg, res] if arg != res
                Arachni::Reactor.stop if cnt == n || mismatches.any?
            end
        end

        wait

        cnt.should > 0
        mismatches.should be_empty
    end

    describe '#initialize' do
        it 'should be able to properly assign class options (including :role)' do
            opts = rpc_opts.merge( role: :client )
            start_client( opts ).opts.should == opts
        end

        context 'when passed no connection information' do
            it 'raises ArgumentError' do
                begin
                    described_class.new({})
                rescue => e
                    e.should be_kind_of ArgumentError
                end
            end
        end

        describe 'option' do
            describe :socket, if: Arachni::Reactor.supports_unix_sockets? do

                it 'connects to it' do
                    client = start_client( rpc_opts_with_socket )
                    client.call( 'test.foo', 1 ).should == 1
                end

                it 'retains stability and consistency under heavy load' do
                    client = start_client( rpc_opts_with_socket )

                    n    = 10_000
                    cnt  = 0

                    mismatches = []

                    n.times do |i|
                        arg = 'a' * i
                        client.call( 'test.foo', arg ) do |res|
                            cnt += 1
                            mismatches << [i, arg, res] if arg != res
                            Arachni::Reactor.stop if cnt == n || mismatches.any?
                        end
                    end
                    wait

                    cnt.should > 0
                    mismatches.should be_empty
                end

                context 'and connecting to a non-existent server' do
                    it 'returns Arachni::RPC::Exceptions::ConnectionError' do
                        options = rpc_opts_with_socket.merge( socket: '/' )

                        response = nil
                        start_client( options ).call( 'test.foo', @arg ) do |res|
                            response = res
                            Arachni::Reactor.stop
                        end
                        wait

                        response.should be_rpc_connection_error
                        response.should be_kind_of Arachni::RPC::Exceptions::ConnectionError
                    end
                end

                context 'when passed an invalid socket path' do
                    it 'raises ArgumentError' do
                        begin
                            described_class.new( socket: 'blah' )
                        rescue => e
                            e.should be_kind_of ArgumentError
                        end
                    end
                end
            end
        end

        context 'when passed a host but not a port' do
            it 'raises ArgumentError' do
                begin
                    described_class.new( host: 'test' )
                rescue => e
                    e.should be_kind_of ArgumentError
                end
            end
        end

        context 'when passed a port but not a host' do
            it 'raises ArgumentError' do
                begin
                    described_class.new( port: 9999 )
                rescue => e
                    e.should be_kind_of ArgumentError
                end
            end
        end

        context 'when passed an invalid port' do
            it 'raises ArgumentError' do
                begin
                    described_class.new( host: 'tt', port: 'blah' )
                rescue => e
                    e.should be_kind_of ArgumentError
                end
            end
        end
    end

    describe '#call' do
        it 'can handle remote method that delay their results' do
            start_client( rpc_opts ).call( 'test.delay', @arg ).should == @arg
        end

        it 'can handle remote method that defer their results' do
            start_client( rpc_opts ).call( 'test.defer', @arg ).should == @arg
        end

        context 'when using Threads' do
            it 'should be able to perform synchronous calls' do
                @arg.should == start_client( rpc_opts ).call( 'test.foo', @arg )
            end

            it 'should be able to perform asynchronous calls' do
                response = nil
                start_client( rpc_opts ).call( 'test.foo', @arg ) do |res|
                    response = res
                    Arachni::Reactor.stop
                end
                wait

                response.should == @arg
            end
        end

        context 'when run inside the Reactor loop' do
            it 'should be able to perform asynchronous calls' do
                response = nil

                Arachni::Reactor.stop
                Arachni::Reactor.global.run do
                    start_client( rpc_opts ).call( 'test.foo', @arg ) do |res|
                        response = res
                        Arachni::Reactor.stop
                    end
                end

                response.should == @arg
            end

            it 'should not be able to perform synchronous calls' do
                exception = nil

                Arachni::Reactor.stop
                Arachni::Reactor.global.run do
                    begin
                        start_client( rpc_opts ).call( 'test.foo', @arg )
                    rescue => e
                        exception = e
                        Arachni::Reactor.stop
                    end
                end

                exception.should be_kind_of RuntimeError
            end
        end

        context 'when performing an asynchronous call' do
            context 'and connecting to a non-existent server' do
                it 'returns Arachni::RPC::Exceptions::ConnectionError' do
                    response = nil

                    options = rpc_opts.merge( host: 'dddd', port: 999339 )
                    start_client( options ).call( 'test.foo', @arg ) do |res|
                        response = res
                        Arachni::Reactor.stop
                    end
                    wait

                    response.should be_rpc_connection_error
                    response.should be_kind_of Arachni::RPC::Exceptions::ConnectionError
                end
            end

            context 'and requesting a non-existent object' do
                it 'returns Arachni::RPC::Exceptions::InvalidObject' do
                    response = nil

                    start_client( rpc_opts ).call( 'bar.foo' ) do |res|
                        response = res
                        Arachni::Reactor.stop
                    end
                    wait

                    response.should be_rpc_invalid_object_error
                    response.should be_kind_of Arachni::RPC::Exceptions::InvalidObject
                end
            end

            context 'and requesting a non-public method' do
                it 'returns Arachni::RPC::Exceptions::InvalidMethod' do
                    response = nil

                    start_client( rpc_opts ).call( 'test.bar' ) do |res|
                        response = res
                        Arachni::Reactor.stop
                    end
                    wait

                    response.should be_rpc_invalid_method_error
                    response.should be_kind_of Arachni::RPC::Exceptions::InvalidMethod
                end
            end

            context 'and there is a remote exception' do
                it 'returns Arachni::RPC::Exceptions::RemoteException' do
                    response = nil
                    start_client( rpc_opts ).call( 'test.foo' ) do |res|
                        response = res
                        Arachni::Reactor.stop
                    end
                    wait

                    response.should be_rpc_remote_exception
                    response.should be_kind_of Arachni::RPC::Exceptions::RemoteException
                end
            end
        end

        context 'when performing a synchronous call' do
            context 'and connecting to a non-existent server' do
               it 'raises Arachni::RPC::Exceptions::ConnectionError' do
                   begin
                       options = rpc_opts.merge( host: 'dddd', port: 999339 )
                       start_client( options ).call( 'test.foo', @arg )
                   rescue => e
                       e.rpc_connection_error?.should be_true
                       e.should be_kind_of Arachni::RPC::Exceptions::ConnectionError
                   end
               end
            end

            context 'and requesting a non-existent object' do
                it 'raises Arachni::RPC::Exceptions::InvalidObject' do
                    begin
                        start_client( rpc_opts ).call( 'bar2.foo' )
                    rescue => e
                        e.rpc_invalid_object_error?.should be_true
                        e.should be_kind_of Arachni::RPC::Exceptions::InvalidObject
                    end
                end
            end

            context 'and requesting a non-public method' do
                it 'raises Arachni::RPC::Exceptions::InvalidMethod' do
                    begin
                        start_client( rpc_opts ).call( 'test.bar2' )
                    rescue => e
                        e.rpc_invalid_method_error?.should be_true
                        e.should be_kind_of Arachni::RPC::Exceptions::InvalidMethod
                    end
                end
            end

            context 'and there is a remote exception' do
                it 'raises Arachni::RPC::Exceptions::RemoteException' do
                    begin
                        start_client( rpc_opts ).call( 'test.foo' )
                    rescue => e
                        e.rpc_remote_exception?.should be_true
                        e.should be_kind_of Arachni::RPC::Exceptions::RemoteException
                    end
                end
            end
        end

        context 'when using valid SSL configuration' do
            it 'should be able to establish a connection' do
                res = start_client( rpc_opts_with_ssl_primitives ).call( 'test.foo', @arg )
                res.should == @arg
            end
        end

        context 'when using invalid SSL configuration' do
            it 'should not be able to establish a connection' do
                response = nil

                Arachni::Reactor.stop
                Arachni::Reactor.global.run do
                    start_client( rpc_opts_with_invalid_ssl_primitives ).call( 'test.foo', @arg ) do |res|
                        response = res
                        Arachni::Reactor.stop
                    end
                end

                response.should be_rpc_connection_error
            end
        end

        context 'when using mixed SSL configuration' do
            it 'should not be able to establish a connection' do
                response = nil

                Arachni::Reactor.stop
                Arachni::Reactor.global.run do
                    start_client( rpc_opts_with_mixed_ssl_primitives ).
                        call( 'test.foo', @arg ) do |res|
                        response = res
                        Arachni::Reactor.stop
                    end
                end

                response.should be_rpc_connection_error
                response.should be_rpc_ssl_error
            end
        end
    end

end
