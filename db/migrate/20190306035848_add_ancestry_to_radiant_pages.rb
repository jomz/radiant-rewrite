class AddAncestryToRadiantPages < ActiveRecord::Migration[5.2]
  def change
    add_column :radiant_pages, :ancestry, :string
    add_index :radiant_pages, :ancestry
    add_index :radiant_pages, %w{slug ancestry}, name: 'pages_child_slug'
    
    remove_column :radiant_pages, :parent_id, :integer
  end
end
