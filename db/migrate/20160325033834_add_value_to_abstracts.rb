class AddValueToAbstracts < ActiveRecord::Migration
  def change
    add_column :abstracts, :value, :decimal
    add_column :abstracts, :currency, :string
  end
end
