# frozen_string_literal: true

class ProductPicker
  def initialize(agent)
    @agent = agent
  end

  def products(like, limit = 20)
    results = Product.where(nil)
    results = results.where.not(id: @agent.products.map(&:id))
    results = results.where("identifier like ? or name like ?", "%#{like}%", "%#{like}%")
    results = results.order(identifier: :asc)
    results = results.limit(limit)
    results = results.map { |product| ["#{product.identifier} (#{product.name})", product.id] }
    results
  end
end
