jQuery ->
  L.mapbox.accessToken = 'pk.eyJ1IjoicGVja29taW5nbyIsImEiOiJoVHNQM29zIn0.AVmpyDYApR5mryMCJB1ryw'
  map = L.mapbox.map('map', 'peckomingo.lb8m2cga').setView([
    48.22
    16.379
  ], 11)
  coords = $('#map').data('coords')
  console.log coords
  map.eachLayer (layer) ->
    if layer instanceof L.Marker
      map.removeLayer layer
    return

  # point = L.geoJson($('#map').data('address')).addTo(map)
  # graetzl = L.geoJson(map.featureLayer._geojson)
  # results = leafletPip.pointInLayer(point, graetzl)
  gjLayer = L.geoJson(map._geojson)
  results = leafletPip.pointInLayer([
    coords[1]
    coords[0]
  ], gjLayer)

  console.log gjLayer
  console.log results

  if results.length != 0
    console.log 'got results'

  L.mapbox.featureLayer(
    type: 'Feature'
    geometry:
      type: 'Point'
      coordinates: [
        coords[0]
        coords[1]
      ]
    properties:
      description: '1718 14th St NW, Washington, DC'
      'marker-size': 'large'
      'marker-color': '#BE9A6B'
      'marker-symbol': 'cafe').addTo map

  map.setView [
    coords[1]
    coords[0]
  ], 16