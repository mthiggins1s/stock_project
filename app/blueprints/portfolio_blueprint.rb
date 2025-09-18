class PortfolioBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :created_at, :updated_at

  association :stocks, blueprint: StockBlueprint
end
