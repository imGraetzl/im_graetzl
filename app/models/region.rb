class Region
  attr_reader :id, :name, :use_districts, :area
  # (Maybe PLZ Range: The first two digits of the zip code)

  def initialize(id, name, use_districts, area)
    @id = id
    @name = name
    @use_districts = use_districts
    @area = area
  end

  def self.all
    @regions ||= [
      new('wien', 'Wien', true, {
        "features": [
          {
            "type": "Feature",
            "geometry": {
              "coordinates": [ [ [ 16.429221972063939, 48.320892580446341 ], [ 16.438983538735268, 48.317322094074449 ], [ 16.441633391703185, 48.292424694880935 ], [ 16.473506122658208, 48.276892982175724 ], [ 16.482608719501762, 48.293677035000385 ], [ 16.503416242927113, 48.290864996639712 ], [ 16.516128973307325, 48.286038118914654 ], [ 16.50791274360715, 48.274104338610812 ], [ 16.533861100415223, 48.262603292978469 ], [ 16.548214487432826, 48.263499813028936 ], [ 16.540645976266184, 48.243336636245012 ], [ 16.553976462478936, 48.239497826421911 ], [ 16.537500771031432, 48.200935146043491 ], [ 16.55067783019302, 48.177548267724305 ], [ 16.550999159186002, 48.165137810893235 ], [ 16.576387069121719, 48.162309837312343 ], [ 16.578219440077365, 48.144922712613294 ], [ 16.577255987550867, 48.135697598225221 ], [ 16.544556556973248, 48.143697190518886 ], [ 16.515008411034799, 48.159417949336365 ], [ 16.478701650500238, 48.155051750670594 ], [ 16.454587854675793, 48.13939973901595 ], [ 16.434334136700841, 48.138365538817297 ], [ 16.438228701114038, 48.120419933482076 ], [ 16.414025622641567, 48.118731975808423 ], [ 16.38954234739435, 48.125861071819457 ], [ 16.367087762224738, 48.128891862206011 ], [ 16.325796537008358, 48.138286274586086 ], [ 16.313396343442434, 48.120024896777579 ], [ 16.299745048030232, 48.125818305579458 ], [ 16.268386917550586, 48.134074710762185 ], [ 16.237235221850312, 48.130505497447338 ], [ 16.220089701683829, 48.124258390061264 ], [ 16.219275150990406, 48.128564275789671 ], [ 16.223724324814963, 48.135982235113779 ], [ 16.199152862412333, 48.155047213300485 ], [ 16.183076337318866, 48.1715330023072 ], [ 16.200993360554452, 48.186668813958313 ], [ 16.210799524240645, 48.210139371488204 ], [ 16.186349293357544, 48.223715558925491 ], [ 16.197501178266393, 48.250428919928908 ], [ 16.209258760810737, 48.264609780021068 ], [ 16.235025659242712, 48.250788665794886 ], [ 16.257987472178687, 48.243412940555771 ], [ 16.290215835246784, 48.271022119686471 ], [ 16.31578230744994, 48.274494318130685 ], [ 16.346377817429453, 48.286081932875511 ], [ 16.364395939908135, 48.282812053143836 ], [ 16.396390511844341, 48.323076275890649 ], [ 16.429221972063939, 48.320892580446341 ] ] ],
              "type": "Polygon"
            }
          }
        ]}
      ),
      new('kaernten', 'Kärnten', false, {
        "features": [
          {
            "type": "Feature",
            "geometry": {
              "coordinates": [[[14.522985,46.608595],[14.53594,46.61934],[14.556448,46.623894],[14.575709,46.632831],[14.581953,46.643283],[14.601492,46.637726],[14.61864,46.641392],[14.640201,46.652321],[14.653556,46.645212],[14.65627,46.627987],[14.680713,46.634235],[14.691162,46.628453],[14.709736,46.634946],[14.73242,46.636668],[14.726771,46.657569],[14.711233,46.664015],[14.707665,46.684256],[14.728737,46.69539],[14.74511,46.689604],[14.773158,46.670777],[14.775807,46.680268],[14.80401,46.67628],[14.799333,46.691674],[14.768836,46.713993],[14.80299,46.728417],[14.816676,46.724651],[14.842874,46.736846],[14.860029,46.71977],[14.874369,46.727085],[14.887485,46.720578],[14.904027,46.726689],[14.920077,46.761847],[14.946303,46.78104],[14.97262,46.785833],[14.955654,46.795217],[14.927596,46.791065],[14.903197,46.783564],[14.887288,46.78706],[14.869566,46.779574],[14.845869,46.777875],[14.833384,46.802195],[14.813861,46.808155],[14.790549,46.800607],[14.751957,46.80489],[14.750047,46.809904],[14.7265,46.809982],[14.710034,46.803389],[14.688004,46.808322],[14.649654,46.826359],[14.653557,46.816246],[14.644858,46.802886],[14.670217,46.793357],[14.709599,46.763077],[14.692205,46.751976],[14.675512,46.756538],[14.667622,46.739459],[14.678669,46.712483],[14.680975,46.695868],[14.648428,46.702841],[14.635216,46.717532],[14.616498,46.721944],[14.598217,46.707468],[14.588415,46.711473],[14.573361,46.73277],[14.563131,46.721037],[14.551461,46.732898],[14.533447,46.742008],[14.526178,46.735627],[14.524714,46.712375],[14.506624,46.706308],[14.494595,46.687104],[14.513932,46.676766],[14.532162,46.661428],[14.503222,46.649388],[14.525192,46.629456],[14.522985,46.608595]]],
              "type": "Polygon"
            }
          }
        ]}
      ),
      new('muehlviertler-kernland', 'Mühlviertler Kernland', false, {
        "features": [
          {
            "type": "Feature",
            "geometry": {
              "coordinates": [[[14.434334,48.359782],[14.435339,48.362046],[14.429865,48.366203],[14.433049,48.369134],[14.439696,48.36765],[14.442657,48.369097],[14.441024,48.373201],[14.447399,48.375742],[14.451264,48.376351],[14.450228,48.379342],[14.463537,48.38093],[14.463962,48.387039],[14.460694,48.392595],[14.463644,48.396256],[14.457268,48.401494],[14.451891,48.402876],[14.447468,48.410626],[14.441571,48.410521],[14.430342,48.414903],[14.431976,48.417998],[14.427872,48.420087],[14.427128,48.42771],[14.421072,48.431861],[14.408033,48.433398],[14.407873,48.437522],[14.41126,48.44794],[14.4062,48.450186],[14.403489,48.456531],[14.396675,48.463691],[14.396674,48.467043],[14.400499,48.470741],[14.404364,48.471455],[14.401057,48.475496],[14.397072,48.476896],[14.39767,48.480997],[14.381652,48.493987],[14.375157,48.493855],[14.373147,48.498888],[14.380199,48.499495],[14.376454,48.505514],[14.368066,48.510304],[14.368982,48.516243],[14.373963,48.516481],[14.37213,48.520518],[14.375876,48.523738],[14.371333,48.527987],[14.368326,48.531979],[14.370557,48.534855],[14.381515,48.534063],[14.381117,48.538786],[14.384942,48.538232],[14.387253,48.530475],[14.394373,48.536452],[14.392939,48.539064],[14.400031,48.543206],[14.40828,48.541491],[14.413064,48.54416],[14.417407,48.542555],[14.420834,48.536566],[14.427767,48.53617],[14.432389,48.534957],[14.433625,48.536672],[14.433784,48.542687],[14.426253,48.543241],[14.422627,48.542396],[14.420953,48.542845],[14.420117,48.545588],[14.415893,48.546116],[14.413967,48.549972],[14.404843,48.550974],[14.403129,48.555563],[14.399163,48.560413],[14.400557,48.564316],[14.400223,48.57185],[14.395162,48.572377],[14.39066,48.579495],[14.388317,48.582897],[14.385169,48.583662],[14.383299,48.592528],[14.389276,48.594899],[14.396647,48.593028],[14.412466,48.59316],[14.424865,48.588387],[14.432436,48.596399],[14.432665,48.599151],[14.439279,48.602523],[14.441998,48.609374],[14.445823,48.615011],[14.444508,48.620438],[14.453369,48.625813],[14.446715,48.635425],[14.441523,48.640548],[14.441164,48.644498],[14.456306,48.644287],[14.464913,48.647018],[14.467185,48.649256],[14.4736,48.642779],[14.473979,48.639773],[14.490196,48.633769],[14.492722,48.627517],[14.497304,48.61951],[14.50344,48.617955],[14.51298,48.620748],[14.522463,48.615953],[14.537497,48.615442],[14.546223,48.613387],[14.549172,48.608145],[14.559019,48.604312],[14.562336,48.609144],[14.568991,48.612121],[14.573334,48.613623],[14.578036,48.617363],[14.580097,48.616775],[14.587309,48.618619],[14.59229,48.621122],[14.596519,48.626036],[14.59903,48.625799],[14.603492,48.629407],[14.608832,48.628406],[14.61196,48.62464],[14.616622,48.619583],[14.620008,48.611577],[14.624045,48.604929],[14.629583,48.604112],[14.634086,48.607169],[14.640572,48.610229],[14.644238,48.610492],[14.651338,48.604862],[14.655083,48.59809],[14.660503,48.582751],[14.668352,48.582303],[14.679692,48.583392],[14.686267,48.585527],[14.688777,48.581309],[14.707509,48.579901],[14.714442,48.573021],[14.718825,48.569434],[14.721335,48.56308],[14.728229,48.562526],[14.735484,48.556904],[14.73385,48.55337],[14.725482,48.552077],[14.720581,48.547989],[14.713567,48.543043],[14.706474,48.544573],[14.699461,48.540194],[14.695118,48.533203],[14.687895,48.524562],[14.679285,48.526568],[14.675619,48.523058],[14.664861,48.522609],[14.659003,48.51704],[14.66093,48.507933],[14.661926,48.500488],[14.668302,48.498772],[14.667983,48.496422],[14.664795,48.49592],[14.670334,48.490903],[14.672406,48.488209],[14.66864,48.485723],[14.667923,48.481946],[14.665412,48.481339],[14.66099,48.484323],[14.656686,48.488391],[14.652542,48.487545],[14.652941,48.475607],[14.649779,48.471868],[14.647986,48.463704],[14.646941,48.45795],[14.645985,48.449203],[14.642149,48.447647],[14.636825,48.435164],[14.637662,48.433843],[14.634543,48.416566],[14.637452,48.414953],[14.633313,48.411354],[14.630843,48.409185],[14.633353,48.405614],[14.630604,48.403286],[14.633831,48.400826],[14.635931,48.393351],[14.626727,48.390811],[14.626182,48.383648],[14.626899,48.376476],[14.622595,48.374173],[14.620713,48.371327],[14.625216,48.369051],[14.624618,48.366721],[14.630635,48.365795],[14.634619,48.362009],[14.635183,48.359829],[14.629923,48.354295],[14.635581,48.351065],[14.638527,48.346605],[14.638647,48.340142],[14.630199,48.337732],[14.6294,48.326299],[14.633186,48.325822],[14.633744,48.323305],[14.628404,48.323835],[14.627328,48.320338],[14.629037,48.318106],[14.627762,48.313893],[14.621984,48.315563],[14.621705,48.312542],[14.617322,48.312144],[14.615688,48.314529],[14.610986,48.315192],[14.608038,48.313496],[14.611186,48.311084],[14.613935,48.307877],[14.610912,48.302824],[14.604417,48.302135],[14.593322,48.305302],[14.58607,48.299471],[14.577623,48.298054],[14.572563,48.303647],[14.567856,48.306953],[14.570964,48.312068],[14.571004,48.317924],[14.560775,48.321446],[14.545455,48.326948],[14.540394,48.331796],[14.536529,48.329412],[14.533362,48.330475],[14.522723,48.341309],[14.516011,48.344604],[14.516011,48.348788],[14.513142,48.349901],[14.518283,48.353846],[14.51478,48.358307],[14.517729,48.360928],[14.504017,48.365124],[14.494813,48.363271],[14.486764,48.370922],[14.480398,48.36911],[14.479402,48.365139],[14.481473,48.35614],[14.468914,48.355052],[14.458674,48.354205],[14.455167,48.352748],[14.437675,48.356614],[14.434334,48.359782]]],
              "type": "Polygon"
            }
          }
        ]}
      ),
    ]
  end

  def self.get(id)
    all.find{|r| r.id == id }
  end

  def use_districts?
    @use_districts
  end

  def to_s
    name
  end

  def host
    if id == 'wien'
      Rails.application.config.imgraetzl_host
    else
      "#{id}.#{Rails.application.config.welocally_host}"
    end
  end

  def districts
    return [] if !use_districts?
    @districts ||= District.all_memoized.values.select{|d| d.region_id == id }
  end

  def graetzls
    @graetzls ||= Graetzl.all_memoized.values.select{|g| g.region_id == id }
  end

end
