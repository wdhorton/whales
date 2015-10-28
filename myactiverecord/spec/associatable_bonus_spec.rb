require 'associatable_bonus'

describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Dog < SQLObject
      has_many :walkings
      finalize!
    end

    class Walking < SQLObject
      belongs_to :dog
      belongs_to :human
      finalize!
    end

    class Human < SQLObject
      has_many :walkings
      self.table_name = "humans"
      finalize!
    end
  end

  describe "has_many :through" do
    before(:all) do
      class Human
        has_many :dogs, through: :walkings, source: :dog

        finalize!
      end
    end

    let(:human) { Human.find(1) }
    let(:lonely_human) { Human.find(4) }

    it 'adds getter method' do
      expect(human).to respond_to(:dogs)
    end

    it 'gets the correct dogs for this human' do
      results = human.dogs
      names = results.map { |result| result.name }.sort

      expect(names).to eq(['Fido', 'Rex', 'Rover'])
    end

    it "returns nil when human has no dogs" do
      expect(lonely_human.dogs).to be_nil
    end
  end


end
