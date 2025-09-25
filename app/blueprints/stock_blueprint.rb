class StockBlueprint < Blueprinter::Base
  identifier :id

  fields :symbol, :name, :current_price
end
