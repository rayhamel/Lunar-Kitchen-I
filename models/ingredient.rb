# Deals with ingredient data.
class Ingredient
  attr_reader :id, :name, :recipe_id
  def initialize(id, name, recipe_id)
    @id = id
    @name = name
    @recipe_id = recipe_id
  end
end
