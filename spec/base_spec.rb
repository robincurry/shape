require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Shape::Base do

  context 'Given an object with method attributes' do

    let(:source) {
      OpenStruct.new.tap do |person|
      person.name  = 'John Smith'
      person.age   = 34
      person.ssn   = 123456789
      person.children = [
        OpenStruct.new.tap do |child|
        child.name  = 'Jimmy Smith'
        end,
          OpenStruct.new.tap do |child|
          child.name  = 'Jane Smith'
          end,
      ]
      end
    }

    context 'and a Shape decorator' do

      before do
        stub_const('MockDecorator', Class.new do
          include Shape::Base
          property :name
          property :years_of_age, from: :age
        end)

      end

      context 'when shaped by the decorator' do

        subject {
          MockDecorator.new(source)
        }

        it 'exposes defined properties from source' do
          expect(subject.name).to eq('John Smith')
        end

        it 'exposes defined properties renamed from source' do
          expect(subject.years_of_age).to eq(34)
        end

        it 'does not expose unspecified attributes' do
          expect(subject).to_not respond_to(:ssn)
          expect(subject).to_not respond_to(:age)
        end
      end
    end

    context 'and Parent and Child Shape decorators' do

      before do
        stub_const('ChildDecorator', Class.new do
          include Shape::Base
          property :name
        end)

        stub_const('ParentDecorator', Class.new do
          include Shape::Base
          property :name
          property :years_of_age, from: :age

          association :children, each_with: ChildDecorator
        end)
      end

      context 'when shaped by the decorator' do

        subject {
          ParentDecorator.new(source)
        }

        it 'exposes and shapes children associations' do
          expect(subject.children.map(&:name)).to eq(['Jimmy Smith', 'Jane Smith'])
        end

      end

    end

  end

  context 'Given a hash with method attributes' do

    let(:source) {
      {
        name: 'John Smith',
        age: 34,
        ssn: 123456789,
        children: [
          {
            name: 'Jimmy Smith'
          },
          {
            name: 'Jane Smith'
          }
        ]
      }
    }

    context 'and a Shape decorator' do

      before do
        stub_const('MockDecorator', Class.new do
          include Shape::Base
          property :name
          property :years_of_age, from: :age
        end)

      end

      context 'when shaped by the decorator' do

        subject {
          MockDecorator.new(source)
        }

        it 'exposes defined properties from source' do
          expect(subject.name).to eq('John Smith')
        end

        it 'exposes defined properties renamed from source' do
          expect(subject.years_of_age).to eq(34)
        end

        it 'does not expose unspecified attributes' do
          expect(subject).to_not respond_to(:ssn)
          expect(subject).to_not respond_to(:age)
        end
      end

    end

    context 'and Parent and Child Shape decorators' do

      before do
        stub_const('ChildDecorator', Class.new do
          include Shape::Base
          property :legal_name, from: :name
        end)

        stub_const('ParentDecorator', Class.new do
          include Shape::Base
          property :name
          property :years_of_age, from: :age

          association :children, each_with: ChildDecorator
        end)
      end

      context 'when shaped by the decorator' do

        subject {
          ParentDecorator.new(source)
        }

        it 'exposes and shapes children associations' do
          expect(subject.children.map(&:legal_name)).to eq(['Jimmy Smith', 'Jane Smith'])
        end

      end

    end

    context 'and a Shape decorator with properties_from' do

      before do
        stub_const('MockDecorator', Class.new do
          include Shape::Base
          properties_from(:keys)
        end)

      end

      context 'when shaped by the decorator' do

        subject {
          MockDecorator.new(source)
        }

        it 'exposes defined properties from source for each key' do
          expect(subject).to respond_to(:name, :age, :ssn, :children)
          expect(subject.name).to eq('John Smith')
        end
      end

    end

    context 'and a Shape decorator with properties_from with an except list' do

      before do
        stub_const('MockDecorator', Class.new do
          include Shape::Base
          properties_from(:keys, except: :ssn)
        end)
      end

      context 'when shaped by the decorator' do

        subject {
          MockDecorator.new(source)
        }

        it 'should not expose defined properties for the exceptions' do
          expect(subject).to_not respond_to(:ssn)
        end
      end

    end
  end

end
