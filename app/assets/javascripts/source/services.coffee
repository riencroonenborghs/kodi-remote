app = angular.module "kodiRemote.services", []

app.service "Request", [ "$http", "$q", "$websocket", ($http, $q, $websocket) ->
  service =
    fetch: (method, handler, params) ->
      deferred = $q.defer()

      errorHandler = (response) ->
        console.error "wsRequest ERROR - #{new Date()}"
        console.error response
        console.error "wsRequest ERROR ---------------"

      successHandler = (parsedResponse) ->
        if parsedResponse.result
          data = handler parsedResponse.result
          if parsedResponse.result == "OK"
            deferred.resolve {data: data, total: 0}
          else
            total = if parsedResponse.result.limits then parsedResponse.result.limits.total else null
            deferred.resolve {data: data, total: total}
        return

      payload = {jsonrpc: "2.0", method: method, id: 1, params: params}

      if kodiRemote.settings.requestType == "http"
        httpSuccessHandler = (response) -> successHandler response.data
        $http.post("http://#{kodiRemote.settings.server}:#{kodiRemote.settings.port}/jsonrpc", payload).then(httpSuccessHandler, errorHandler)
      else
        websocketSuccessHandler = (response) -> successHandler JSON.parse(response.data)
        websocketObject = $websocket("ws://#{kodiRemote.settings.server}:#{kodiRemote.settings.port}/jsonrpc")
        websocketObject.onError errorHandler
        websocketObject.onMessage websocketSuccessHandler
        websocketObject.send payload

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