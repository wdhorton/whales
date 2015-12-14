#Whales

There's [Rails](https://github.com/rails/rails), there's [Sails](https://github.com/balderdashy/sails), so why not Whales? Whales
is a lightweight web framework written in Ruby, inspired by popular MVC frameworks like Rails, Django, and Express.


##Installation

Whales can be installed using RubyGems:
`gem install 'whales'`

Or you can include it directly in your projects Gemfile:
`gem 'whales', '0.1.1'`

##Your First Whales Project
**Create a new app:**
```
whales new MyApp
```

**Start working:**
```
# cd into the new folder
cd MyApp

# start the server
whales server
```

##Documentation##
###WhalesORM###
WhalesORM is the object-relational mapper behind Whales. It connects to a SQLite
database that the user can create and modify in their `db/database.sql` file.

####`WhalesORM::Base`####
The features of WhalesORM are accessed by making a class that inherits from
`WhalesORM::Base`. The base class provides the following methods:

`::all`: returns all the instances of the class stored in the table.

`::columns`: returns an array with the columns of the class's table.

`::destroy_all`: deletes all the rows in the class's table.

`::find(id)`: returns the object of the class with the given id.

`::find_by_col_x(value)`: returns the object(s) of the class whose `col_x` equals `value`. Implemented using Ruby's `method_missing`. Also can be extended to
`::find_by_col_x_and_col_y(val_x, val_y)`.

`::table_name=(name)`: allows the user to set a custom table name for the class

`::table_name`: returns the table name, which defaults to the pluralized,
camel-cased class name.


`#attributes`: returns the names of all the attributes for the object.

`#attribute_values`: returns the values for all the object's attributes.

`#destroy`: deletes the object from the database. Returns the object.

`#insert`: inserts the object as a row in the class's table

`#save`: if the object is not in the database, it `insert`s it; if it is, it calls
`update`.

`#update`: updates the object's entry in the database

####`WhalesORM::QueryMethods`####
`WhalesORM::Base` gains additional methods by extending the `WhalesORM::QueryMethods`
module.

`::where(params)`: gets objects from the database that match the given params hash.
This method is chainable and lazy-evaluating.

This is implemented using a `WhalesORM::Relation` class that inherits from Ruby's
`BasicObject`. It puts off the database call until it gets a method call it doesn't
recognize.

```ruby
module WhalesORM
  class Relation < BasicObject
    ...
    def method_missing(method, *args, &blk)
      results = self.execute
      results.send(method, *args, &blk)
    end
    ...
  end
end
```

`::includes(relation)`: helps to prevent N+1 queries by including the given relation
in the query. Also lazy-evaluating.

####`WhalesORM::Associatable`####
`WhalesORM::Base` also extends `WhalesORM::Associatable`.

`::belongs_to(relation_name)`: associates the class to `relation_name` via a foreign key `relation_name_id` so that the method `#relation_name` returns an object of class `relation_name` with id equal to `relation__name_id`
