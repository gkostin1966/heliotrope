# frozen_string_literal: true

json.extract! identifier, :id, :name, :email, :created_at, :updated_at
json.url identifier_url(identifier, format: :json)
