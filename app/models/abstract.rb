class Abstract < ActiveRecord::Base
  belongs_to :context, polymorphic: true
  belongs_to :item, polymorphic: true
  belongs_to :project
  belongs_to :user
end
