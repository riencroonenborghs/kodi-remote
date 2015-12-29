app = angular.module "kodiRemote.playlist.services", []

app.service "Playlist", [ "Request", (Request) ->
  emptyHandler = -> return

  itemsHandler = (result) -> 
    for item in (result.items || [])
      item.thumbnail = kodiRemote.parseImage item.thumbnail
    return result.items || []

  service = 
    playlistId: 1

    clear: -> 
      params = [@playlistId]
      return Request.fetch "Playlist.Clear", emptyHandler, params

    remove: (index) ->
      params = [@playlistId, index]
      return Request.fetch "Playlist.Remove", emptyHandler, params

    addEpisode: (episodeId) -> 
      params = [@playlistId, {episodeid: episodeId}]
      return Request.fetch "Playlist.Add", emptyHandler, params

    addMovie: (movieId) -> 
      params = [@playlistId, {movieid: movieId}]
      return Request.fetch "Playlist.Add", emptyHandler, params
      
    items: ->
      properties = ["title", "showtitle", "playcount", "season", "episode", "thumbnail", "tvshowid", "uniqueid", "art"]
      params = 
        playlistid: @playlistId
        properties: properties
      return Request.fetch "Playlist.GetItems", itemsHandler, params
    
  service
]