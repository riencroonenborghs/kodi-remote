app = angular.module "kodiRemote.services", []

app.service "Request", [ "$websocket", "$q", ($websocket, $q) ->
  service =
    # websocket: $websocket("ws://#{kodiRemote.settings.server}:#{kodiRemote.settings.port}/jsonrpc")
    fetch: (method, handler, params) ->
      deferred = $q.defer()

      errorHandler = (response) ->
        console.error "wsRequest ERROR - #{new Date()}"
        console.error response
        console.error "wsRequest ERROR ---------------"        

      messagehandler = (response) ->
        parsedResponse  = JSON.parse response.data
        
        if parsedResponse.result
          data = handler parsedResponse.result
          if parsedResponse.result == "OK"
            deferred.resolve {data: data, total: 0}
          else
            total = if parsedResponse.result.limits then parsedResponse.result.limits.total else null
            deferred.resolve {data: data, total: total}
        return

      payload = {jsonrpc: "2.0", method: method, id: 1, params: params}
      
      # @websocket.onError errorHandler
      # @websocket.onMessage messagehandler
      # @websocket.send payload

      w = $websocket("ws://#{kodiRemote.settings.server}:#{kodiRemote.settings.port}/jsonrpc")
      w.onError errorHandler
      w.onMessage messagehandler
      w.send payload

      deferred.promise

  service
]

app.service "SearchService", [ "TvShows", "Movies", (TvShows, Movies) ->
  service =
    tvShows:    []
    tvShowGroups: []
    movies:     []
    movieGroups: []
    searching:  false

    reset: -> 
      @tvShows    = []
      @movies     = []
      @searching  = false

    search: (query) ->
      return unless query.length > 2

      searchingTvShows  = true
      searchingMovies   = true
      @searching        = searchingTvShows && searchingMovies

      @tvShows    = []
      @movies     = []

      TvShows.where.title(query).then (tvShowsData) =>
        @tvShows          = tvShowsData.data
        @tvShowGroups     = kodiRemote.array.inGroupsOf @tvShows, 2
        searchingTvShows  = false
        @searching        = searchingTvShows && searchingMovies

      Movies.where.title(query).then (moviesData) =>
        @movies         = moviesData.data
        @movieGroups    = kodiRemote.array.inGroupsOf @movies, 2
        searchingMovies = true
        @searching      = searchingTvShows && searchingMovies

      return

  service
]

app.service "Files", [ "Request", (Request) ->
  prepareDownloadResultHandler = (result) -> return result

  service =
    prepareDownload: (file) ->
      params = [file]
      return Request.fetch "Files.PrepareDownload", prepareDownloadResultHandler, params
]