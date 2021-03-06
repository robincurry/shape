require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Shape::DataVisitor do

  context 'Given a decorated class that implements Shape::DataVisitor' do

    before do
      stub_const('FamilyMember', Class.new do
        include Shape
        property :name
        property :age
      end)

      stub_const('ParentDecorator', Class.new do
        include Shape
        property :name
        property :age
        association :spouse, with: FamilyMember
        association :children, each_with: FamilyMember
      end)
    end

    context 'when I visit an object with relations' do
      let(:source) {
        OpenStruct.new.tap do |person|
          person.name  = 'John Smith'
          person.age   = 34
          person.spouse = OpenStruct.new.tap do |spouse|
            spouse.name  = 'Jane Smith'
            spouse.age = 32
          end
          person.children = [
            OpenStruct.new.tap do |spouse|
              spouse.name  = 'Sally Smith'
              spouse.age = 5
            end
          ]
        end
      }

      context 'without providing a visitor' do
        subject {
          ParentDecorator.new(source).visit
        }

        it 'returns the raw visited data' do
          expect(subject[:name]).to eq('John Smith')
          expect(subject[:age]).to eq(34)
          expect(subject[:spouse][:name]).to eq('Jane Smith')
          expect(subject[:spouse][:age]).to eq(32)
          expect(subject[:children].first[:name]).to eq('Sally Smith')
          expect(subject[:children].first[:age]).to eq(5)
        end
      end

      context 'with a string visitor' do
        subject {
          ParentDecorator.new(source).visit(lambda do |data|
            data.to_s
          end)
        }

        it 'returns the visited data as strings' do
          expect(subject[:name]).to eq('John Smith')
          expect(subject[:age]).to eq('34')
          expect(subject[:spouse][:age]).to eq('32')
          expect(subject[:children].first[:age]).to eq('5')
        end
      end

    end

    context 'when I visit an object with empty relations' do
      let(:source) {
        OpenStruct.new.tap do |person|
          person.name  = 'John Smith'
          person.age   = 34
          person.spouse = nil
          person.children = []
        end
      }

      context 'without providing a visitor' do
        subject {
          ParentDecorator.new(source).visit
        }

        it 'returns the raw visited data' do
          expect(subject).to include(:spouse)
          expect(subject[:spouse]).to eq(nil)
          expect(subject[:children]).to eq([])
        end
      end

      context 'with a string visitor' do
        subject {
          ParentDecorator.new(source).visit(lambda do |data|
            data.to_s
          end)
        }

        it 'returns the raw visited data' do
          expect(subject).to include(:spouse)
          expect(subject[:spouse]).to eq(nil)
          expect(subject[:children]).to eq([])
        end
      end

      context 'and a Shape decorator property with if: option' do

        before do
          stub_const('MockDecorator', Class.new do
            include Shape
            property :name
            property :ssn , if: ->{ _source[:secure] }

            property :private do
              property :age, if: -> { _source[:secure] }
            end
          end)

        end

        context 'when false' do

          before do
            source.secure = false
          end

          subject {
            MockDecorator.new(source)
          }

          it 'does not include the property' do
            expect(subject.to_json).not_to include('ssn')
          end

          it 'does not include the nested property' do
            expect(subject.to_json).not_to include('age')
          end

        end

        context 'when true' do

          before do
            source.secure = true
          end

          subject {
            MockDecorator.new(source)
          }

          it 'includes the property' do
            expect(subject.to_json).to include('ssn')
          end

          it 'includes the nested property' do
            expect(subject.to_json).to include('age')
          end

        end

      end

    end

  end

end
