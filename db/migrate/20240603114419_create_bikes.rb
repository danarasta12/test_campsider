class CreateBikes < ActiveRecord::Migration[7.1]
  def change
    create_table :bikes do |t|
      t.string :marque
      t.string :prix_neuf
      t.string :modele
      t.string :annee
      t.string :gamme
      t.string :poids
      t.string :fiche_technique
      t.string :photo_url
      t.timestamps
    end
  end
end
