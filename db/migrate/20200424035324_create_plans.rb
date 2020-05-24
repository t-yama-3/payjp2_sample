class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.integer :amount, null:false
      t.string :interval, null:false
      t.string :name
      t.integer :trial_days
      t.integer :billing_day
      t.string :plan_token, null:false
      t.timestamps
    end
  end
end
