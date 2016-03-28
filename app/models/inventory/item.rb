class Inventory::Item < ActiveRecord::Base
  belongs_to :context, polymorphic: true
  belongs_to :project
end
