require 'spec_helper'

class Translator < Arachni::RPC::Proxy

    translate :foo do |response|
        response.map(&:to_s)
    end

    translate :delay do |response, arguments|
        [arguments, response.map(&:to_s)]
    end

end

describe Arachni::RPC::Proxy do

    def wait
        Arachni::Reactor.global.wait rescue Arachni::Reactor::Error::NotRunning
    end

    before(:each) do
        if Arachni::Reactor.global.running?
            Arachni::Reactor.stop
        end

        Arachni::Reactor.global.run_in_thread
    end

    let(:translated_arguments) do
        arguments.map(&:to_s)
    end
    let(:arguments) do
        [
            'one',
            2,
            { three: 3 },
            [ 4 ]
        ]
    end
    let(:reactor) { Arachni::Reactor.global }
    let(:client) { start_client( rpc_opts ) }
    let(:handler) { 'test' }
    let(:translator) { Translator.new( client, handler ) }
    subject do
        Arachni::RPC::Proxy.new( client, handler )
    end

    it 'forwards synchronous calls' do
        subject.foo( arguments ).should == arguments
    end

    it 'forwards synchronous calls' do
        response = nil
        subject.foo( arguments ) do |res|
            response = res
            Arachni::Reactor.stop
        end
        wait

        response.should == arguments
    end

    describe '.translate' do
        it 'translates synchronous calls' do
            translator.foo( arguments ).should == translated_arguments
        end

        it 'translates asynchronous calls' do
            response = nil
            translator.foo( arguments ) do |res|
                response = res
                Arachni::Reactor.stop
            end
            wait

            response.should == translated_arguments
        end

        it 'passes the method arguments to the translator' do
            translator.delay( arguments ).should == [arguments, translated_arguments]
        end
    end
end
