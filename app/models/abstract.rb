class Abstract < ActiveRecord::Base
  default_scope { order(created_at: :desc) }
  belongs_to :context, polymorphic: true
  belongs_to :item, polymorphic: true
  belongs_to :project
  belongs_to :user
end
