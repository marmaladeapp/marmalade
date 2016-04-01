class Categorization < ActiveRecord::Base
  belongs_to :category, polymorphic: true
  belongs_to :item, polymorphic: true

  #include Abstractable
  #default_scope { order(created_at: :asc) }

  #belongs_to :user, :inverse_of => :subscriber_categorizations

  validates_presence_of :category, unless: Proc.new { |categorization| item.present? }
  validates_presence_of :item, unless: Proc.new { |categorization| category.present? }

  def global_category
    self.category.to_global_id if self.category.present?
  end
  def global_category=(category)
    self.category = GlobalID::Locator.locate category
  end

end
