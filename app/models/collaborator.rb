class Collaborator < ActiveRecord::Base
  belongs_to :subscriber, :class_name => "User", counter_cache: true
  belongs_to :collaborator, :class_name => "User", counter_cache: true
end
