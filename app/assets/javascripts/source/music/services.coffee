app = angular.module "kodiRemote.music.services", []

app.service "Albums", [ "Request", "Songs", (Request, Songs) ->
  properties = ["title", "description", "artist", "genre", "mood", "style", "albumlabel", "rating", "year", "thumbnail", "playcount", "genreid", "artistid", "fanart"]
  
  allResultHandler = (result) ->
    for album in (result.albums || [])
      album.type = "album"
      album.songs = -> Songs.all @.albumid
      album.thumbnail = kodiRemote.imageObject album.thumbnail
    return result.albums || []

  getResultHandler = (result) ->
    result.albumdetails.type = "album"
    result.albumdetails.songs = -> Songs.all @.albumid
    return result.albumdetails

  service = 
    perPage: 10

    all: (pageParams = 1, sortParams = {by: "artist", direction: "ascending"}) ->
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
  properties = ["title", "description", "artist", "genre", "mood", "style", "albumlabel", "rating", "year", "thumbnail", "playcount", "genreid", "artistid", "fanart"]

  resultHandler = (result) ->
    for season in (result.songs || [])
      season.type = "song"
      # season.episodes = -> Episodes.all @.tvshowid, @.season
    return result.songs || []

  service = 
    all: (albumId) ->
      params =
        albumid: albumId
        properties: properties

      return Request.fetch "AudioLibrary.GetSongs", resultHandler, params
    
  service
]