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

  def esterhazygasse_hash
    {"type"=>"Feature",
      "geometry"=>
      {"type"=>"Point",
        "coordinates"=>[16.353172456228375, 48.194235057984216]},
        "bbox"=>[48.194235057984216, 16.353172456228375, 16.353172456228375, 48.194235057984216],
        "properties"=>{
          "Bezirk"=>"6",
          "Adresse"=>"Esterházygasse 5",
          "CountryCode"=>"AT",
          "StreetName"=>"Esterházygasse",
          "StreetNumber"=>"5",
          "CountrySubdivision"=>"Wien",
          "Municipality"=>"Wien",
          "MunicipalitySubdivision"=>"Mariahilf",
          "Kategorie"=>"Adresse",
          "Zaehlbezirk"=>"0602",
          "Zaehlgebiet"=>"06029",
          "Ranking"=>0.0,
          "PostalCode"=>"1060"}}
  end
end