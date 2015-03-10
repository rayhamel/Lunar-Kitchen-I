require 'pg'
require_relative 'ingredient'

def db_connection
  connection = PG.connect(dbname: 'recipes')
  yield(connection)
  ensure
    connection.close
end

class Recipe
  def initialize(id, name, instructions, description)
    @id = id
    @name = name
    @instructions = instructions
    @description = description
  end

  attr_reader :id, :name, :instructions, :description

  def ingredients
    db_connection do |conn|
      query = conn.exec_params(
        'SELECT ingredients.id, ingredients.name, ingredients.recipe_id FROM ' \
        'ingredients JOIN recipes ON recipes.id = ingredients.recipe_id WHERE' \
        ' recipes.id = $1', [@id]
      )
      ingredients_list = []
      query.each do |q|
        ingredients_list << Ingredient.new(q['id'], q['name'], q['recipe_id'])
      end
      ingredients_list
    end
  end

  def self.all
    all_recipes = db_connection { |conn| conn.exec('SELECT * FROM recipes') }
    all_recipes_ary = []
    all_recipes.each do |recipe|
      all_recipes_ary << Recipe.new(
        recipe['id'], recipe['name'], recipe['instructions'],
        recipe['description']
      )
    end
    all_recipes_ary
  end

  def self.find(id)
    db_connection do |conn|
      query = conn.exec_params('SELECT * FROM recipes WHERE id = $1', [id])[0]
      Recipe.new(
        query['id'], query['name'], query['instructions'],
        query['description']
      )
    end
    rescue IndexError
      Recipe.new(
        id, "This recipe doesn't have a name.",
        "This recipe doesn't have any instructions.",
        "This recipe doesn't have a description."
      )
  end
end
