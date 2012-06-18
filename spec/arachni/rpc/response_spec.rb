describe Arachni::RPC::Response do

    before( :all ) do
        @r = Arachni::RPC::Response
    end

    describe '#obj' do
        it 'should be an accessor' do
            r = @r.new
            r.obj = 'test'
            r.obj.should == 'test'
        end
    end

    describe '#async?' do
        context 'by default' do
            it 'should return false' do
                @r.new.async?.should be_false
            end
        end

        context 'after #async!' do
            it 'should return false' do
                r = @r.new
                r.async!
                r.async?.should be_true
            end
        end
    end
end
