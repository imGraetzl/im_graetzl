module GeojsonSupport
  def feature_hash
    {"type"=>"Feature",
        "geometry"=>{
          "type"=>"Point",
          "coordinates"=>[16.35955137895887, 48.20137456512505]},
          "bbox"=>[48.20137456512505, 16.35955137895887, 16.35955137895887, 48.20137456512505],
          "properties"=>{
            "Bezirk"=>"7",
            "Adresse"=>"Mariahilfer Straße 10",
            "CountryCode"=>"AT",
            "StreetName"=>"Mariahilfer Straße",
            "StreetNumber"=>"10",
            "CountrySubdivision"=>"Wien",
            "Municipality"=>"Wien",
            "MunicipalitySubdivision"=>"Neubau",
            "Kategorie"=>"Adresse",
            "Zaehlbezirk"=>"0702",
            "Zaehlgebiet"=>"07023",
            "Ranking"=>0.0,
            "PostalCode"=>"1070"}}
  end

  def feature_json
    feature_hash.to_json
  end
end