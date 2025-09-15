class StockBlueprint < Blueprinter::Base
  identifier :symbol

  # Core fields
  fields :name, :current_price

  field :price do |stock, _|
    stock.respond_to?(:current_price) ? stock.current_price : 0
  end

  field :change do |stock, _|
    stock.respond_to?(:change) ? stock.change : nil
  end

  field :change_percent do |stock, _|
    stock.respond_to?(:change_percent) ? stock.change_percent : nil
  end

  field :logo_url do |stock, _|
    stock.respond_to?(:logo_url) ? stock.logo_url : nil
  end
end
