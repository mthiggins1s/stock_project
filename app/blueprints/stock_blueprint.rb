# app/blueprints/stock_blueprint.rb
class StockBlueprint < Blueprinter::Base
  # Identifier for API responses
  identifier :symbol

  # Core fields
  fields :name, :current_price

  view :detailed do
    fields :exchange, :sector, :industry
  end
end
