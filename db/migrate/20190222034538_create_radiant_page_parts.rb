class CreateRadiantPageParts < ActiveRecord::Migration[5.2]
  def change
    create_table :radiant_page_parts do |t|
      t.string :name
      t.text :content
      t.string :filter_id
      t.integer :page_id

      t.timestamps
    end
    
    add_index :radiant_page_parts, %w{page_id name}, name: 'parts_by_page'
  end
end
