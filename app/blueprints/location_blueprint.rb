# frozen_string_literal: true

class LocationBlueprint < Blueprinter::Base
  identifier :id
  fields :zip_code, :city, :state, :country, :address
end
