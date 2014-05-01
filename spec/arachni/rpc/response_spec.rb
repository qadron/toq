require 'spec_helper'

describe Arachni::RPC::Response do
    subject { described_class.new }

    describe '#obj' do
        it 'should be an accessor' do
            subject.obj = 'test'
            subject.obj.should == 'test'
        end
    end

    describe '#async?' do
        context 'by default' do
            it 'should return false' do
                subject.async?.should be_false
            end
        end

        context 'after #async!' do
            it 'should return false' do
                subject.async!
                subject.async?.should be_true
            end
        end
    end
end
