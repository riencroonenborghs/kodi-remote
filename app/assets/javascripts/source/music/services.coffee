app = angular.module "kodiRemote.music.services", []

app.service "Albums", [ "Request", "Songs", (Request, Songs) ->
  properties = ["title", "description", "artist", "genre", "mood", "style", "albumlabel", "rating", "year", "thumbnail", "playcount", "genreid", "artistid", "fanart"]
  
  allResultHandler = (result) ->
    for show in (result.albums || [])
      show.type = "album"
      show.songs = -> Songs.all @.albumid
    return result.albums || []

  getResultHandler = (result) ->
    result.albumdetails.type = "album"
    result.albumdetails.songs = -> Songs.all @.albumid
    return result.albumdetails

  service = 
    perPage: 5

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

# app.service "Episodes", [ "Request", (Request) ->
#   properties    = ["title", "plot", "rating", "writer", "firstaired", "playcount", "runtime", "director", "season", "episode", "cast", "thumbnail", "resume", "showtitle", "tvshowid"]
  
#   resultHandler = (result) -> 
#     for episode in (result.episodes || [])
#       episode.type = "episode"
#     return result.episodes || []

#   getResultHandler = (result) -> 
#     result.episodedetails.type = "episode"
#     result.episodedetails

#   service = 
#     all: (tvShowId, season) -> 
#       params =
#         tvshowid: tvShowId
#         season: season
#         properties: properties
#       return Request.fetch "VideoLibrary.GetEpisodes", resultHandler, params

#     get: (episodeId) ->
#       params =
#         episodeid: episodeId
#         properties: properties
               
#       return Request.fetch "VideoLibrary.GetEpisodeDetails", getResultHandler, params
    
#   service
# ]