class UserBlueprint < Blueprinter::Base
  identifier :public_id

  fields :username, :first_name, :last_name, :email, :created_at, :updated_at

  view :extended do
    association :portfolios, blueprint: PortfolioBlueprint
  end
end
