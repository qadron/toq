require File.join( File.expand_path( File.dirname( __FILE__ ) ), '../../', 'spec_helper' )

describe Arachni::RPC::Request do

    before( :all ) do
        @r = Arachni::RPC::Request
    end

    describe '#message' do
        it 'should be an accessor' do
            r = @r.new
            r.message = 'test'
            r.message.should == 'test'
        end
    end

    describe '#args' do
        it 'should be an accessor' do
            r = @r.new
            r.args = %w(test)
            r.args.should == %w(test)
        end
    end

    describe '#token' do
        it 'should be an accessor' do
            r = @r.new
            r.token = 'blah'
            r.token.should == 'blah'
        end
    end

    describe '#callback' do
        it 'should be an accessor' do
            r = @r.new
            called = false
            r.callback = proc { called = true }
            r.callback.call
            called.should be_true
        end
    end

    describe '#prepare_for_tx' do
        it 'should convert the request to a hash ready for transmission' do
            r = @r.new
            r.prepare_for_tx.should be_empty

            r = @r.new( message: 'obj.method', args: %w(test), token: 'mytoken',
                callback: proc{}
            )
            r.prepare_for_tx.should be_eql( "args" => %w(test), "message" => "obj.method", "token" => "mytoken" )
        end
    end

end
