module Abstractable
  extend ActiveSupport::Concern

  included do
    has_many :item_abstracts, :as => :item, :class_name => 'Abstract'

    before_destroy do |resource|
      resource.item_abstracts.update_all(item_id: nil)
    end

  end


  private



end
