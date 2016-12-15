class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes_hash)
    @id= attributes_hash[:id]
    @name = attributes_hash[:name]
    @breed = attributes_hash[:breed]
  end

  def self.create(attributes_hash)
    Dog.new(attributes_hash).save
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    Dog.new(id:row[0], name:row[1], breed:row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?;
    SQL

    row = DB[:conn].execute(sql, name).first
    Dog.new_from_db(row)
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end

  def save
    if self.id
      update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?);
      SQL

      row = DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?;
    SQL

    row = DB[:conn].execute(sql, id)[0]
    Dog.new_from_db(row)
  end

  def self.find_or_create_by(attributes_hash)
# => when two dogs have the same name and different breed, it returns the correct dog (FAILED - 2)
# => when creating a new dog with the same name as persisted dogs, it returns the correct dog

    if !self.find_by_id(attributes_hash[:id])
      self.create(attributes_hash)
    elsif self.find_by_name(attributes_hash[:name]) > 1


    self.create(attributes_hash)
  end
end