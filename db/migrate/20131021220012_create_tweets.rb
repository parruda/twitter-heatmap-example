class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
          t.integer :tid
      t.string :text
      t.datetime :date
      t.string :source
      t.integer :uid
      t.string :screen_name
      t.string :name
      t.integer :followers_count
      t.integer :friends_count
      t.integer :statuses_count
      t.string :time_zone
      t.float :latitude
      t.float :longitude
      t.boolean :gmaps
      t.timestamps
    end
  end
end
