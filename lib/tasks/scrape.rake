task scrape: :environment do
  desc "Scrape data from Big Bike Magazine (VTT From Scott brand only) - Case study Campsider"
  require 'open-uri'
  require 'httparty'
  require 'json'
  require 'csv'

  # Nombre d'annonces par page
  annonces_par_page = 1

  # Nombre total d'annonces à scraper (à titre indicatif)
  response_nb = HTTParty.get('https://www.bigbike-magazine.com/vtt-resultat-recherche?formId=140313540&_annee%5B%5D=&_marque%5B%5D=13339&_gamme%5B%5D=&_prix%5B%5D=0-16499', {
    headers: { "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"},
  })
  nombre_total_annonces = 27

  # Liste pour stocker les vélos
  bikes = []

  # Boucle de pagination
  (0..nombre_total_annonces).step(annonces_par_page).each do |offset|
    next if offset == 1
    url = "https://www.bigbike-magazine.com/vtt-resultat-recherche/#{offset}?formId=140313540&_annee%5B%5D=&_marque%5B%5D=13339&_gamme%5B%5D=&_prix%5B%5D=0-16499"

    response = HTTParty.get(url, {
      headers: { "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"},
    })

    doc = Nokogiri::HTML(response.body)

    annonces = doc.search('.resultats')

    annonces.each do |annonce|

      marque = annonce.at_css(".marque").text.strip
      annonce_url = 'https://www.bigbike-magazine.com/' + annonce.at_css("a")['href']
      photo_url = 'https://www.bigbike-magazine.com/' + annonce.at_css(".thumbs-results2 img")['src']
      modele = annonce.at_css(".mod").text.strip
      annee = annonce.at_css(".annee").text.strip.to_i
      gamme = annonce.at_css(".gamme").text.strip
      prix_neuf = annonce.at_css(".prix").text.gsub(/[^\d]/, '').strip.to_i
      # Ouvrir le lien de l'annonce pour récupérer des informations supplémentaires
      annonce_response = HTTParty.get(annonce_url, {
        headers: { "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"},
      })

      annonce_doc = Nokogiri::HTML(annonce_response.body)
      poids = annonce_doc.at_css(".col-left .infos:nth-child(2) .infos-valeurs").text.gsub(' kg','').strip
      fiche_technique = annonce_doc.at_css('#fiche-technique div:nth-child(2)').text.strip + annonce_doc.at_css('#geometrie div:nth-child(2)').text.strip

      bikes << {
        marque: marque,
        prix_neuf: prix_neuf,
        modele: modele,
        annee: annee,
        gamme: gamme,
        poids: poids,
        fiche_technique: fiche_technique,
        photo_url: photo_url,
        annonce_url: annonce_url
      }

      puts 'Added: ' + modele + ' | Marque : ' + marque
    end
  end

  # Écrire les vélos dans un fichier JSON
  File.open("bikes.json", "w") do |f|
    f.write(JSON.pretty_generate(bikes))
  end

  # Écrire les vélos dans un fichier JSON
  CSV.open("bikes.csv", "w") do |csv|
    csv << bikes.first.keys # Ajoute les en-têtes CSV
    bikes.each do |bike|
      csv << bike.values
    end
  end

  puts "Saved all bikes to bikes.json and bikes.csv"
  puts "Nombre de vélos :" + bikes.count
end
