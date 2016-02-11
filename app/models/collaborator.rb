class Collaborator < ActiveRecord::Base
  belongs_to :subscriber, :class_name => "User"
  belongs_to :collaborator, :class_name => "User"
end
