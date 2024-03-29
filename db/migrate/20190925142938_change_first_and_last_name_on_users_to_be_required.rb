# frozen_string_literal: true

class ChangeFirstAndLastNameOnUsersToBeRequired < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :first_name, :string, null: false
    change_column :users, :last_name, :string, null: false
  end
end
