require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Property child associations" do

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

    context 'and Parent and Child Shaper decorators' do

      before do
        stub_const('ChildDecorator', Class.new do
          include Shaper::Base
          property :name
        end)

        stub_const('ParentDecorator', Class.new do
          include Shaper::Base
          property :name
          property :years_of_age, from: :age

          association :children, with: ChildDecorator
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

  context 'Given a hash with attributes' do

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


    context 'and Parent and Child Shaper decorators' do

      before do
        stub_const('ChildDecorator', Class.new do
          include Shaper::Base
          property :legal_name, from: :name
        end)

        stub_const('ParentDecorator', Class.new do
          include Shaper::Base
          property :name
          property :years_of_age, from: :age

          association :children, with: ChildDecorator
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

  end

  context 'Given a hash with deeply nested attributes' do

    let(:source) {
      {
        name: 'John Smith',
        age: 34,
        ssn: 123456789,
        children: [
          {
            name: 'Jimmy Smith',
            children: [
              {
                name: 'Suzy Smith'
              },
              {
                name: 'Sally Smith'
              }
            ]
          },
          {
            name: 'Jane Smith',
            children: [
              {
                name: 'Sam Smith'
              },
              {
                name: 'Tim Smith'
              },
            ]
          }
        ]
      }
    }


    context 'and Parent and Child Shaper decorators' do

      before do
        stub_const('NestedChildDecorator', Class.new do
          include Shaper::Base
          property :name
        end)

        stub_const('ChildDecorator', Class.new do
          include Shaper::Base
          property :legal_name, from: :name
          association :children, with: NestedChildDecorator
        end)

        stub_const('ParentDecorator', Class.new do
          include Shaper::Base
          property :name
          property :years_of_age, from: :age

          association :children, with: ChildDecorator
        end)
      end

      context 'when shaped by the decorator' do

        subject {
          ParentDecorator.new(source)
        }

        it 'exposes and shapes children associations' do
          expect(subject.children.map(&:legal_name)).to eq(['Jimmy Smith', 'Jane Smith'])
        end

        it 'exposes and shapes nested children associations' do
          expect(subject.children.first.children.map(&:name)).to eq(['Suzy Smith', 'Sally Smith'])
        end

      end

    end

  end

end
