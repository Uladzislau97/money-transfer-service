class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.decimal :balance, precision: 16, scale: 2

      t.timestamps
    end
  end
end
