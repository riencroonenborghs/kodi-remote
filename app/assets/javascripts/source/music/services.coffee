app = angular.module "kodiRemote.music.services", []

app.service "Artists", [ "Request", (Request) ->
  properties = ["description", "genre", "thumbnail"]
  
  allResultHandler = (result) ->
    for artist in (result.artists || [])
      artist.type = "artist"
      artist.thumbnail = kodiRemote.imageObject artist.thumbnail
    return result.artists || []

  service = 
    perPage: 10

    all: (pageParams = 1, sortParams = {by: "label", direction: "ascending"}) ->
      params =
        properties: properties
        sort:
          method: sortParams.by
          order: sortParams.direction
        limits:
          start: (pageParams - 1) * @perPage
          end: pageParams * @perPage       
      return Request.fetch "AudioLibrary.GetArtists", allResultHandler, params
    
  service
]

app.service "Albums", [ "Request", (Request) ->
  properties = ["title", "description", "artist", "genre", "mood", "style", "albumlabel", "rating", "year", "thumbnail", "playcount", "genreid", "artistid", "fanart"]
  
  allResultHandler = (result) ->
    for album in (result.albums || [])
      album.type = "album"      
      album.thumbnail = kodiRemote.imageObject album.thumbnail
    return result.albums || []

  getResultHandler = (result) ->
    result.albumdetails.type = "album"
    result.albumdetails.thumbnail = kodiRemote.imageObject result.albumdetails.thumbnail
    return result.albumdetails

  service = 
    perPage: 10

    all: (pageParams = 1, sortParams = {by: "label", direction: "ascending"}) ->
      params =
        properties: properties
        sort:
          method: sortParams.by
          order: sortParams.direction
        limits:
          start: (pageParams - 1) * @perPage
          end: pageParams * @perPage       
      return Request.fetch "AudioLibrary.GetAlbums", allResultHandler, params

    get: (albumId) ->
      params =
        albumid: albumId
        properties: properties
      return Request.fetch "AudioLibrary.GetAlbumDetails", getResultHandler, params
    
  service
]

app.service "Songs", [ "Request", (Request) ->
  properties = ["title", "artist", "genre", "year", "rating", "album", "track", "duration", "playcount", "thumbnail", "file"]

  resultHandler = (result) ->
    for song in (result.songs || [])
      song.type = "song"
      song.thumbnail = kodiRemote.imageObject song.thumbnail
    return result.songs || []

  service = 
    all: (albumTitle) ->
      params =         
        properties: properties
        filter:
          field: "album"
          operator: "is"
          value: albumTitle
      return Request.fetch "AudioLibrary.GetSongs", resultHandler, params
    
  service
]