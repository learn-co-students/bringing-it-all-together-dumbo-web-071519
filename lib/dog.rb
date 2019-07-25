
require 'pry'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(hash)
    hash.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.new_from_db(row)
    new = Dog.new(name: row[1], breed: row[2])
    new.id = row[0]
    new
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name)
    self.new_from_db(row.first)
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end

  def save
    if self.id
       self.update
    end

    sql = <<-SQL
      INSERT INTO dogs(name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    dog = self.new(hash)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id)
    self.new_from_db(row[0])
  end

  def self.find_or_create_by(hash)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
    if !row.empty?
      dog = Dog.new(name: hash[:name], breed: hash[:breed])
      dog.id = row.first[0]
      dog
    else
      dog = self.create(hash)
    end
    dog
  end


end
