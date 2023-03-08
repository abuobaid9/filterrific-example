class Product < ApplicationRecord
  belongs_to :category

  filterrific(
  default_filter_params: { sorted_by: 'created_at_desc' },
  available_filters: [
    :sorted_by,
    :search_query,
    :with_category_id,
    :with_price_gte,
    :with_price_lte
  ]
)

scope :sorted_by, ->(sort_option) {
  direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
  case sort_option.to_s
  when /^created_at_/
    order("products.created_at #{direction}")
  when /^price_/
    order("products.price #{direction}")
  when /^name_/
    order("products.name #{direction}")
  else
    raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
  end
}

scope :search_query, ->(query) {
  return nil if query.blank?
  terms = query.downcase.split(/\s+/)
  terms = terms.map { |e|
    ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
  }
  num_or_conds = 2
  where(
    terms.map { |term|
      "(LOWER(products.name) LIKE ? OR LOWER(products.desc) LIKE ?)"
    }.join(' AND '),
    *terms.map { |e| [e] * num_or_conds }.flatten
  )
}

scope :with_category_id, ->(category_ids) {
  where(category_id: [*category_ids])
}

scope :with_price_gte, ->(price) {
  where('price >= ?', price)
}
scope :with_price_lte, ->(price) {
  where('price <= ?', price)
}
def self.options_for_sorted_by(sort_option = nil)
  [
    ['Product name (A-Z)', 'name_asc'],
    ['Product name (Z-A)', 'name_desc'],
    ['Price (Lowest first)', 'price_asc'],
    ['Price (Highest first)', 'price_desc'],
    ['Created date (Newest first)', 'created_at_desc'],
    ['Created date (Oldest first)', 'created_at_asc']
  ]
end
end
