class ADF.Cluster.Views.Cluster 

  constructor : (markerClusterer) ->
    @markerClusterer_ = markerClusterer
    @map_ = markerClusterer.getMap()
    @gridSize_ = markerClusterer.getGridSize()
    @minClusterSize_ = markerClusterer.getMinClusterSize()
    @averageCenter_ = markerClusterer.isAverageCenter()
    @center_ = null
    @markers_ = []
    @bounds_ = null
    if @markerClusterer_.getClusterShowType() == "chart"
      @clusterIcon_ = new ADF.Cluster.Views.ChartIcon(this, markerClusterer.getStyles(), markerClusterer.getGridSize(), markerClusterer.getFillColors())
    else
      @clusterIcon_ = new ADF.Cluster.Views.DefaultIcon(this, markerClusterer.getStyles(), markerClusterer.getGridSize())

  isMarkerAlreadyAdded : (marker) ->
    if @markers_.indexOf
      return @markers_.indexOf(marker) isnt -1
    else
      i = 0
      m = undefined

      while m = @markers_[i]
        return true  if m is marker
        i++
    false

  addMarker : (marker) ->
    return false  if @isMarkerAlreadyAdded(marker)
    unless @center_
      @center_ = marker.getPosition()
      @calculateBounds_()
    else
      if @averageCenter_
        l = @markers_.length + 1
        lat = (@center_.lat() * (l - 1) + marker.getPosition().lat()) / l
        lng = (@center_.lng() * (l - 1) + marker.getPosition().lng()) / l
        @center_ = new google.maps.LatLng(lat, lng)
        @calculateBounds_()
    marker.isAdded = true
    @markers_.push marker
    len = @markers_.length
    
    # Min cluster size not reached so show the marker.
    marker.setMap @map_  if len < @minClusterSize_ and marker.getMap() isnt @map_
    marker.getMarker().setMap @map_  if len < @minClusterSize_ and marker.getMarker() and marker.getMarker().getMap() isnt @map_
    if len is @minClusterSize_
      
      # Hide the markers that were showing.
      i = 0

      while i < len
        @markers_[i].setMap null
        @markers_[i].getMarker().setMap null if @markers_[i].getMarker()
        i++
    marker.setMap null  if len >= @minClusterSize_
    marker.getMarker().setMap null  if len >= @minClusterSize_ and marker.getMarker()
    @updateIcon()
    true

  getMarkerClusterer : ->
    @markerClusterer_

  getBounds : ->
    bounds = new google.maps.LatLngBounds(@center_, @center_)
    markers = @getMarkers()
    i = 0
    marker = undefined

    while marker = markers[i]
      bounds.extend marker.getPosition()
      i++
    bounds

  remove : ->
    @clusterIcon_.remove()
    @markers_.length = 0
    delete @markers_

  getClusterIcon: () ->
    @clusterIcon_

  getSize : ->
    @markers_.length

  getMarkers : ->
    @markers_

  getCenter : ->
    @center_

  calculateBounds_ : ->
    bounds = new google.maps.LatLngBounds(@center_, @center_)
    @bounds_ = @markerClusterer_.getExtendedBounds(bounds)

  isMarkerInClusterBounds : (marker) ->
    @bounds_.contains marker.getPosition()

  getMap : ->
    @map_

  updateIcon : ->
    zoom = @map_.getZoom()
    mz = @markerClusterer_.getMaxZoom()
    if mz and zoom > mz
      
      # The zoom is greater than our max zoom so show all the markers in cluster.
      i = 0
      marker = undefined

      while marker = @markers_[i]
        marker.setMap @map_
        marker.getMarker().setMap @map_ if marker.getMarker()
        i++
      return

    if @markers_.length < @minClusterSize_
      
      # Min cluster size not yet reached.
      @clusterIcon_.hide()
      return
    numStyles = @markerClusterer_.getStyles().length
    sums = @markerClusterer_.getCalculator()(@markers_, numStyles)
    @clusterIcon_.setCenter @center_
    @clusterIcon_.setSums sums
    @clusterIcon_.show()