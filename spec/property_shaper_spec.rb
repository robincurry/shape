require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Shape::PropertyShaper do

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

  end

  context 'Given a hash with attributes' do

    let(:source) do
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
    end

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

    context 'and a Shape decorator property with with: option' do

      before do
        stub_const('ChildDecorator', Class.new do
          include Shape::Base
          property :name
        end)

        stub_const('MockDecorator', Class.new do
          include Shape::Base
          property :children, with: ChildDecorator
        end)

      end

      context 'when shaped by the decorator' do

        subject {
          MockDecorator.new(source)
        }

        it 'exposes and shapes each child element of the property with the provided decorator' do
          expect(subject.children.map(&:name)).to eq(['Jimmy Smith', 'Jane Smith'])
        end

      end

    end

    context 'and a Shape decorator property with with: and from: options' do

      before do
        stub_const('ChildDecorator', Class.new do
          include Shape::Base
          property :name
        end)

        stub_const('MockDecorator', Class.new do
          include Shape::Base
          property :dependents, from: :children, with: ChildDecorator
        end)

      end

      context 'when shaped by the decorator' do

        subject {
          MockDecorator.new(source)
        }

        it 'exposes and shapes each child element of the property with the provided decorator' do
          expect(subject.dependents.map(&:name)).to eq(['Jimmy Smith', 'Jane Smith'])
        end

      end

    end

    context 'and a Shape decorator property with with: and from: options and a decorator defined method' do

      before do
        stub_const('ChildDecorator', Class.new do
          include Shape::Base
          property :name
        end)

        stub_const('MockDecorator', Class.new do
          include Shape::Base
          property :dependents, from: :all_children

          def all_children
            [
              OpenStruct.new.tap do |child|
              child.name  = 'Joseph Smith'
              end,
              OpenStruct.new.tap do |child|
              child.name  = 'Janet Smith'
              end
            ]
          end
        end)

      end

      context 'when shaped by the decorator' do

        subject {
          MockDecorator.new(source)
        }

        it 'exposes and shapes each child element of the property with the provided decorator' do
          expect(subject.dependents.map(&:name)).to eq(['Joseph Smith', 'Janet Smith'])
        end

      end

    end

    context 'and a Shape decorator property using a with block' do

      before do
        stub_const('ChildDecorator', Class.new do
          include Shape::Base
          property :name
        end)

        stub_const('MockDecorator', Class.new do
          include Shape::Base
          property :children do
            with do
              property :name
            end
          end
        end)

      end

      context 'when shaped by the decorator' do

        subject {
          MockDecorator.new(source)
        }

        it 'exposes and shapes each child element of the property with the provided decorator' do
          expect(subject.children.map(&:name)).to eq(['Jimmy Smith', 'Jane Smith'])
        end

      end

    end

    context 'and a Shape decorator property using from: option and a with block' do

      before do
        stub_const('ChildDecorator', Class.new do
          include Shape::Base
          property :name
        end)

        stub_const('MockDecorator', Class.new do
          include Shape::Base
          property :dependents, from: :children do
            with do
              property :name
            end
          end
        end)

      end

      context 'when shaped by the decorator' do

        subject {
          MockDecorator.new(source)
        }

        it 'exposes and shapes each child element of the property with the provided decorator' do
          expect(subject.dependents.map(&:name)).to eq(['Jimmy Smith', 'Jane Smith'])
        end

      end

    end

  end

end
