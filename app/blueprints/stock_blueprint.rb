# app/blueprints/stock_blueprint.rb
class StockBlueprint < Blueprinter::Base
  identifier :symbol

  # Core fields
  fields :name

  field :price do |stock, _options|
    stock.current_price || 0 # fallback so Angular won’t break
  end

  # Only include detailed fields if they actually exist
  view :detailed do
    # Remove or comment out until your schema has them
    # fields :exchange, :sector, :industry
  end
end
