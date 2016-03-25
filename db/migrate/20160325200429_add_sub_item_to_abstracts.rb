class AddSubItemToAbstracts < ActiveRecord::Migration
  def change
    add_reference :abstracts, :sub_item, polymorphic: true, index: true
  end
end
