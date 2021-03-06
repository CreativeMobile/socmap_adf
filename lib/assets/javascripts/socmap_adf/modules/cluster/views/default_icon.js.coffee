class ADF.Cluster.Views.DefaultIcon extends google.maps.OverlayView

  constructor : (cluster, styles, opt_padding) ->
    @styles_ = styles
    @padding_ = opt_padding or 0
    @cluster_ = cluster
    @center_ = null
    @map_ = cluster.getMap()
    @div_ = null
    @sums_ = null
    @visible_ = false
    @setMap @map_

  ###
  Triggers the clusterclick event and zoom's if the option is set.
  ###
  triggerClusterClick : ->
    markerClusterer = @cluster_.getMarkerClusterer()
    
    # Trigger the clusterclick event.
    google.maps.event.trigger markerClusterer, "clusterclick", @cluster_
    
    # Zoom into the cluster.
    @map_.fitBounds @cluster_.getBounds()  if markerClusterer.isZoomOnClick()


  ###
  Adding the cluster icon to the dom.
  @ignore
  ###
  onAdd : ->
    @div_ = document.createElement("DIV")
    if @visible_
      pos = @getPosFromLatLng_(@center_)
      @div_.style.cssText = @createCss(pos)
      @div_.innerHTML = @sums_.text
    panes = @getPanes()
    panes.overlayMouseTarget.appendChild @div_
    that = this
    google.maps.event.addDomListener @div_, "click", ->
      that.triggerClusterClick()

  ###
  Returns the position to place the div dending on the latlng.

  @param {google.maps.LatLng} latlng The position in latlng.
  @return {google.maps.Point} The position in pixels.
  @private
  ###
  getPosFromLatLng_ : (latlng) ->
    pos = @getProjection().fromLatLngToDivPixel(latlng)
    pos.x -= parseInt(@width_ / 2, 10)
    pos.y -= parseInt(@height_ / 2, 10)
    pos


  ###
  Draw the icon.
  @ignore
  ###
  draw : ->
    if @visible_
      pos = @getPosFromLatLng_(@center_)
      @div_.style.top = pos.y + "px"
      @div_.style.left = pos.x + "px"


  ###
  Hide the icon.
  ###
  hide : ->
    @div_.style.display = "none"  if @div_
    @visible_ = false


  ###
  Position and show the icon.
  ###
  show : ->
    if @div_
      pos = @getPosFromLatLng_(@center_)
      @div_.style.cssText = @createCss(pos)
      @div_.style.display = ""
    @visible_ = true


  ###
  Remove the icon from the map
  ###
  remove : ->
    @setMap null


  ###
  Implementation of the onRemove interface.
  @ignore
  ###
  onRemove : ->
    if @div_ and @div_.parentNode
      @hide()
      @div_.parentNode.removeChild @div_
      @div_ = null


  ###
  Set the sums of the icon.

  @param {Object} sums The sums containing:
  'text': (string) The text to display in the icon.
  'index': (number) The style index of the icon.
  ###
  setSums : (sums) ->
    @sums_ = sums
    @text_ = sums.text
    @index_ = sums.index
    @div_.innerHTML = sums.text  if @div_
    @useStyle()


  ###
  Sets the icon to the the styles.
  ###
  useStyle : ->
    index = Math.max(0, @sums_.index - 1)
    index = Math.min(@styles_.length - 1, index)
    style = @styles_[index]
    @url_ = style["url"]
    @height_ = style["height"]
    @width_ = style["width"]
    @textColor_ = style["textColor"]
    @anchor_ = style["anchor"]
    @textSize_ = style["textSize"]
    @backgroundPosition_ = style["backgroundPosition"]


  ###
  Sets the center of the icon.

  @param {google.maps.LatLng} center The latlng to set as the center.
  ###
  setCenter : (center) ->
    @center_ = center


  ###
  Create the css text based on the position of the icon.

  @param {google.maps.Point} pos The position.
  @return {string} The css style text.
  ###
  createCss : (pos) ->
    style = []
    style.push "background-image:url(" + @url_ + ");"
    backgroundPosition = (if @backgroundPosition_ then @backgroundPosition_ else "0 0")
    style.push "background-position:" + backgroundPosition + ";"
    if typeof @anchor_ is "object"
      if typeof @anchor_[0] is "number" and @anchor_[0] > 0 and @anchor_[0] < @height_
        style.push "height:" + (@height_ - @anchor_[0]) + "px; padding-top:" + @anchor_[0] + "px;"
      else
        style.push "height:" + @height_ + "px; line-height:" + @height_ + "px;"
      if typeof @anchor_[1] is "number" and @anchor_[1] > 0 and @anchor_[1] < @width_
        style.push "width:" + (@width_ - @anchor_[1]) + "px; padding-left:" + @anchor_[1] + "px;"
      else
        style.push "width:" + @width_ + "px; text-align:center;"
    else
      style.push "height:" + @height_ + "px; line-height:" + @height_ + "px; width:" + @width_ + "px; text-align:center;"
    txtColor = (if @textColor_ then @textColor_ else "black")
    txtSize = (if @textSize_ then @textSize_ else 11)
    style.push "cursor:pointer; top:" + pos.y + "px; left:" + pos.x + "px; color:" + txtColor + "; position:absolute; font-size:" + txtSize + "px; font-family:Arial,sans-serif; font-weight:bold"
    style.join ""