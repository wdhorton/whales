require '01_sql_object'
require 'securerandom'

describe SQLObject do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:each) do
    class Cat < SQLObject
      self.finalize!
    end

    class Human < SQLObject
      self.table_name = 'humans'

      self.finalize!
    end
  end

  describe '::set_table/::table_name' do
    it '::set_table_name sets table name' do
      expect(Human.table_name).to eq('humans')
    end

    it '::table_name generates default name' do
      expect(Cat.table_name).to eq('cats')
    end
  end

  describe '::columns' do
    it '::columns gets the columns from the table and symbolizes them' do
      expect(Cat.columns).to eq([:id, :name, :owner_id])
    end

    it '::columns creates getter methods for each column' do
      c = Cat.new
      expect(c.respond_to? :something).to be false
      expect(c.respond_to? :name).to be true
      expect(c.respond_to? :id).to be true
      expect(c.respond_to? :owner_id).to be true
    end

    it '::columns creates setter methods for each column' do
      c = Cat.new
      c.name = "Nick Diaz"
      c.id = 209
      c.owner_id = 2
      expect(c.name).to eq 'Nick Diaz'
      expect(c.id).to eq 209
      expect(c.owner_id).to eq 2
    end

    it '::columns created setter methods use attributes hash to store data' do
      c = Cat.new
      c.name = "Nick Diaz"
      expect(c.instance_variables).to eq [:@attributes]
      expect(c.attributes[:name]).to eq 'Nick Diaz'
    end
  end

  describe '#initialize' do
    it '#initialize properly sets values' do
      c = Cat.new(name: 'Don Frye', id: 100, owner_id: 4)
      expect(c.name).to eq 'Don Frye'
      expect(c.id).to eq 100
      expect(c.owner_id).to eq 4
    end

    it '#initialize throws the error with unknown attr' do
      expect do
        Cat.new(favorite_band: 'Anybody but The Eagles')
      end.to raise_error "unknown attribute 'favorite_band'"
    end
  end

  describe '::parse_all' do
    it '::parse_all turns an array of hashes into objects' do
      hashes = [
        { name: 'cat1', owner_id: 1 },
        { name: 'cat2', owner_id: 2 }
      ]

      cats = Cat.parse_all(hashes)
      expect(cats.length).to eq(2)
      hashes.each_index do |i|
        expect(cats[i].name).to eq(hashes[i][:name])
        expect(cats[i].owner_id).to eq(hashes[i][:owner_id])
      end
    end
  end

  describe '::all/::find' do
    it '::all returns all the cats' do
      cats = Cat.all

      expect(cats.count).to eq(5)
      cats.all? { |cat| expect(cat).to be_instance_of(Cat) }
    end

    it '::find finds objects by id' do
      c = Cat.find(1)

      expect(c).not_to be_nil
      expect(c.name).to eq('Breakfast')
    end

    it '::find returns nil if no object has the given id' do
      expect(Cat.find(123)).to be_nil
    end
  end

  describe '#insert' do
    let(:cat) { Cat.new(name: 'Gizmo', owner_id: 1) }

    before(:each) { cat.insert }

    it '#attribute_values returns array of values' do
      cat = Cat.new(id: 123, name: 'cat1', owner_id: 1)

      expect(cat.attribute_values).to eq([123, 'cat1', 1])
    end

    it '#insert inserts a new record' do
      expect(Cat.all.count).to eq(6)
    end

    it '#insert sets the id' do
      expect(cat.id).to_not be_nil
    end

    it '#insert creates record with proper values' do
      # pull the cat again
      cat2 = Cat.find(cat.id)

      expect(cat2.name).to eq('Gizmo')
      expect(cat2.owner_id).to eq(1)
    end
  end

  describe '#update' do
    it '#update changes attributes' do
      human = Human.find(2)

      human.fname = 'Matthew'
      human.lname = 'von Rubens'
      human.update

      # pull the human again
      human = Human.find(2)
      expect(human.fname).to eq('Matthew')
      expect(human.lname).to eq('von Rubens')
    end
  end

  describe '#save' do
    it '#save calls save/update as appropriate' do
      human = Human.new
      expect(human).to receive(:insert)
      human.save

      human = Human.find(1)
      expect(human).to receive(:update)
      human.save
    end
  end
end
