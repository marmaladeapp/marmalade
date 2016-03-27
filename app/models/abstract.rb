class Abstract < ActiveRecord::Base
  default_scope { order(created_at: :desc) }
  belongs_to :context, polymorphic: true
  belongs_to :item, polymorphic: true
  belongs_to :project
  belongs_to :user
  belongs_to :sub_item, polymorphic: true

  def day
    self.created_at.to_date
  end
end
