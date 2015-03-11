require 'pg'
require_relative 'ingredient'

def db_connection
  connection = PG.connect(dbname: 'recipes')
  yield(connection)
  ensure
    connection.close
end

# Deals with recipe data.
class Recipe
  attr_reader :id, :name, :instructions, :description
  def initialize(id, name, instructions, description)
    @id = id
    @name = name
    @instructions = instructions
    @description = description
  end

  def ingredients
    db_connection do |conn|
      query = conn.exec_params(
        'SELECT ingredients.id, ingredients.name, recipe_id FROM ingredients ' \
        'JOIN recipes ON recipes.id = recipe_id WHERE recipes.id = $1', [@id]
      )
      i = []
      query.each { |q| i << Ingredient.new(q['id'], q['name'], q['recipe_id']) }
      i
    end
  end

  def self.all
    all_recipes = db_connection { |conn| conn.exec('SELECT * FROM recipes') }
    ary = []
    all_recipes.each do |r|
      ary << new(r['id'], r['name'], r['instructions'], r['description'])
    end
    ary
  end

  def self.find(id)
    db_connection do |conn|
      query = conn.exec_params('SELECT * FROM recipes WHERE id = $1', [id])[0]
      new(id, query['name'], query['instructions'], query['description'])
    end
    rescue IndexError
      new(
        id, "This recipe doesn't have a name.",
        "This recipe doesn't have any instructions.",
        "This recipe doesn't have a description."
      )
  end
end
