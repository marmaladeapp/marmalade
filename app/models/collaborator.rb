class Collaborator < ActiveRecord::Base
  belongs_to :user, counter_cache: true
  belongs_to :collaborator, :class_name => "User", :foreign_key => 'collaborator_id'
end
