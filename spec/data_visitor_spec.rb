require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Shape::DataVisitor do

  context 'Given a decorated class that implements Shape::DataVisitor' do

    before do
      stub_const('PersonDecorator', Class.new do
        include Shape::Base
        include Shape::DataVisitor
        property :name
        property :age
        association :spouse, with: self
      end)
    end

    let(:source) {
      OpenStruct.new.tap do |person|
        person.name  = 'John Smith'
        person.age   = 34
        person.spouse = OpenStruct.new.tap do |spouse|
          spouse.name  = 'Jane Smith'
          spouse.age = 32
        end
      end
    }

    context 'when I visit the object without providing a visitor' do
      subject {
        PersonDecorator.new(source).visit
      }

      it 'returns the raw visited data' do
        expect(subject[:name]).to eq('John Smith')
        expect(subject[:age]).to eq(34)
        expect(subject[:spouse][:name]).to eq('Jane Smith')
        expect(subject[:spouse][:age]).to eq(32)
      end
    end

    context 'when I visit the object with a string visitor' do
      subject {
        PersonDecorator.new(source).visit(lambda do |data|
          data.to_s
        end)
      }

      it 'returns the visited data as strings' do
        expect(subject[:name]).to eq('John Smith')
        expect(subject[:age]).to eq('34')
        expect(subject[:spouse][:age]).to eq('32')
      end
    end

  end

end
