require 'base'
ROOT_FOLDER = File.join(File.dirname(__FILE__), '../test_db')
SQL_FILE = File.join(ROOT_FOLDER, 'cats.sql')
DB_FILE = File.join(ROOT_FOLDER, 'cats.db')

describe 'AssocOptions' do
  describe 'WhalesORM::BelongsToOptions' do
    it 'provides defaults' do
      options = WhalesORM::BelongsToOptions.new('house')

      expect(options.foreign_key).to eq(:house_id)
      expect(options.class_name).to eq('House')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = WhalesORM::BelongsToOptions.new('owner',
                                     foreign_key: :human_id,
                                     class_name: 'Human',
                                     primary_key: :human_id
      )

      expect(options.foreign_key).to eq(:human_id)
      expect(options.class_name).to eq('Human')
      expect(options.primary_key).to eq(:human_id)
    end
  end

  describe 'WhalesORM::HasManyOptions' do
    it 'provides defaults' do
      options = WhalesORM::HasManyOptions.new('cats', 'Human')

      expect(options.foreign_key).to eq(:human_id)
      expect(options.class_name).to eq('Cat')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = WhalesORM::HasManyOptions.new('cats', 'Human',
                                   foreign_key: :owner_id,
                                   class_name: 'Kitten',
                                   primary_key: :human_id
      )

      expect(options.foreign_key).to eq(:owner_id)
      expect(options.class_name).to eq('Kitten')
      expect(options.primary_key).to eq(:human_id)
    end
  end

  describe 'AssocOptions' do
    before(:all) do
      class Cat < WhalesORM::Base
        self.finalize!
      end

      class Human < WhalesORM::Base
        self.table_name = 'humans'

        self.finalize!
      end
    end

    it '#model_class returns class of associated object' do
      options = WhalesORM::BelongsToOptions.new('human')
      expect(options.model_class).to eq(Human)

      options = WhalesORM::HasManyOptions.new('cats', 'Human')
      expect(options.model_class).to eq(Cat)
    end

    it '#table_name returns table name of associated object' do
      options = WhalesORM::BelongsToOptions.new('human')
      expect(options.table_name).to eq('humans')

      options = WhalesORM::HasManyOptions.new('cats', 'Human')
      expect(options.table_name).to eq('cats')
    end
  end
end

describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Cat < WhalesORM::Base
      belongs_to :human, foreign_key: :owner_id

      finalize!
    end

    class Human < WhalesORM::Base
      self.table_name = 'humans'

      has_many :cats, foreign_key: :owner_id
      has_many :walkings
      belongs_to :house

      finalize!
    end

    class House < WhalesORM::Base
      has_many :humans

      finalize!
    end

    class Dog < WhalesORM::Base
      has_many :walkings
      finalize!
    end

    class Walking < WhalesORM::Base
      belongs_to :dog
      belongs_to :human
      finalize!
    end
  end

  describe '#belongs_to' do
    let(:breakfast) { Cat.find(1) }
    let(:devon) { Human.find(1) }

    it 'fetches `human` from `Cat` correctly' do
      expect(breakfast).to respond_to(:human)
      human = breakfast.human

      expect(human).to be_instance_of(Human)
      expect(human.fname).to eq('Devon')
    end

    it 'fetches `house` from `Human` correctly' do
      expect(devon).to respond_to(:house)
      house = devon.house

      expect(house).to be_instance_of(House)
      expect(house.address).to eq('26th and Guerrero')
    end

    it 'returns nil if no associated object' do
      stray_cat = Cat.find(5)
      expect(stray_cat.human).to eq(nil)
    end
  end

  describe '#has_many' do
    let(:ned) { Human.find(3) }
    let(:ned_house) { House.find(2) }

    it 'fetches `cats` from `Human`' do
      expect(ned).to respond_to(:cats)
      cats = ned.cats

      expect(cats.length).to eq(2)

      expected_cat_names = %w(Haskell Markov)
      2.times do |i|
        cat = cats[i]

        expect(cat).to be_instance_of(Cat)
        expect(cat.name).to eq(expected_cat_names[i])
      end
    end

    it 'fetches `humans` from `House`' do
      expect(ned_house).to respond_to(:humans)
      humans = ned_house.humans

      expect(humans.length).to eq(1)
      expect(humans[0]).to be_instance_of(Human)
      expect(humans[0].fname).to eq('Ned')
    end

    it 'returns an empty array if no associated items' do
      catless_human = Human.find(4)
      expect(catless_human.cats).to be_empty
    end
  end

  describe '::assoc_options' do
    it 'defaults to empty hash' do
      class TempClass < WhalesORM::Base
      end

      expect(TempClass.assoc_options).to eq({})
    end

    it 'stores `belongs_to` options' do
      cat_assoc_options = Cat.assoc_options
      human_options = cat_assoc_options[:human]

      expect(human_options).to be_instance_of(WhalesORM::BelongsToOptions)
      expect(human_options.foreign_key).to eq(:owner_id)
      expect(human_options.class_name).to eq('Human')
      expect(human_options.primary_key).to eq(:id)
    end

    it 'stores options separately for each class' do
      expect(Cat.assoc_options).to have_key(:human)
      expect(Human.assoc_options).to_not have_key(:human)

      expect(Human.assoc_options).to have_key(:house)
      expect(Cat.assoc_options).to_not have_key(:house)
    end
  end

  describe '#has_one_through' do
    before(:all) do
      class Cat
        has_one_through :home, :human, :house

        self.finalize!
      end
    end

    let(:cat) { Cat.find(1) }

    it 'adds getter method' do
      expect(cat).to respond_to(:home)
    end

    it 'fetches associated `home` for a `Cat`' do
      house = cat.home

      expect(house).to be_instance_of(House)
      expect(house.address).to eq('26th and Guerrero')
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
