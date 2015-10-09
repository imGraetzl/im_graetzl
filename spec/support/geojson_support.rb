module GeojsonSupport
  def feature_hash(x = 10, y = 10, bez = '7', zip = '1070')
    {"type"=>"Feature",
        "geometry"=>{
          "type"=>"Point",
          "coordinates"=>[x, y]},
          "bbox"=>[y, x, x, y],
          "properties"=>{
            "Bezirk"=>bez,
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
            "PostalCode"=>zip}}
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