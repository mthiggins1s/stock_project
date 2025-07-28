# frozen_string_literal: true

class UserBlueprint < Blueprinter::Base
  identifier :id

  view :normal do
    fields :username
  end

  view :profile do
    association :location, blueprint: LocationBlueprint
  end
end
