class ProfileBlueprint < Blueprinter::Base
  identifier :id

  fields :bio, :avatar_url, :created_at, :updated_at

  association :location, blueprint: LocationBlueprint
end
