class CreateClientApps < ActiveRecord::Migration
  def change
    create_table :client_apps do |t|
      t.string :name
      t.text :return_uri, limit: 500
      t.string :client_id
      t.string :client_secret
      t.integer :owner_id
      t.timestamps
    end
  end
end
