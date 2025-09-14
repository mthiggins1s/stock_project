class ProfileBlueprint < Blueprinter::Base
  identifier :id

  fields :bio, :avatar_url, :created_at

  view :normal do
    association :user, blueprint: UserBlueprint, view: :profile
  end
end
