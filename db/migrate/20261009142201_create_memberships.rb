class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.references :organization, null: false, foreign_key: true
      t.string :role, null: false, default: "staff"

      t.timestamps
    end

    add_check_constraint :memberships, "role IN ('staff', 'admin')", name: "memberships_role_check"
  end
end
