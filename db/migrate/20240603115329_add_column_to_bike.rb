class AddColumnToBike < ActiveRecord::Migration[7.1]
  def change
    add_column :bikes, :annonce_url, :string
  end
end
