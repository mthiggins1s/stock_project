class UserBlueprint < Blueprinter::Base
  identifier :id

  # Base fields (safe to expose generally)
  fields :username, :first_name, :last_name, :public_id

  view :normal do
    # Logged-in user sees email
    fields :email
  end

  view :profile do
    # Public-facing profile view
    fields :username, :first_name, :last_name, :public_id
    association :location, blueprint: LocationBlueprint
  end
end
