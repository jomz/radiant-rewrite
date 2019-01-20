class CreateRadiantPages < ActiveRecord::Migration[5.2]
  def change
    create_table :radiant_pages do |t|
      t.string :title
      t.string :slug,           limit: 100
      t.string :breadcrumb,     limit: 160
      t.integer :status_id,     default: 1, null: false
      t.integer :parent_id
      t.datetime :published_at
      t.boolean :virtual,       default: false
      t.integer :lock_version,  default: 0
      t.string :class_name,     limit: 25

      t.timestamps
    end
    
    add_index :radiant_pages, :class_name,            name: 'pages_class_name'
    add_index :radiant_pages, :parent_id,             name: 'pages_parent_id'
    add_index :radiant_pages, %w{slug parent_id},     name: 'pages_child_slug'
    add_index :radiant_pages, %w{virtual status_id},  name: 'pages_published'
  end
end
