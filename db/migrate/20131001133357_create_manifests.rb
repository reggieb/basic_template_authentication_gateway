class CreateManifests < ActiveRecord::Migration
  def change
    create_table :manifests do |t|
      t.string :code
      t.string :access_token
      t.string :refresh_token
      t.string :state
      t.text :redirect_uri, limit: 500
      t.datetime :expires_at
      t.integer :client_app_id

      t.timestamps
    end
  end
end
