class Collaborator < ActiveRecord::Base
  # TODO: May have fucked up the migration. Check and correct.
  belongs_to :subscriber, :class_name => "User", counter_cache: true
  belongs_to :collaborator, :class_name => "User", counter_cache: true
end
