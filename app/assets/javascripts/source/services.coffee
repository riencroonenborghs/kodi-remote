app = angular.module "kodiRemote.services", []

app.service "Topbar", [->
  service =    
    item: null
    setTitle: (title) -> @item = {type: "title", title: title}
    setLink: (url, label) -> @item = {type: "link", url: url, label: label}

  service
]

app.service "KodiRequest", [ "$q", "$http", ($q, $http) ->  
  request = (payload) ->
    deferred = $q.defer()

    success = (response) ->
      deferred.reject response unless response.data
      deferred.reject response.data.error if response.data.error
      deferred.resolve response.data.result
      return

    error = (response) -> 
      console.debug error response
      deferred.reject response
      return

    $http.post("http://#{kodiRemote.settings.server}:#{kodiRemote.settings.port}/jsonrpc", payload).then(success, error)

    return deferred.promise

  methodRequest = (method, params = {}) ->
    payload = {jsonrpc: "2.0", method: method, id: 1}
    if params
      payload.params = params
    return request(payload)

  perPage = 10

  service =
    methodRequest: methodRequest
        
  service
]


app.service "Request", [ "$q", "$http", ($q, $http) ->  
  fetch = (method, resultHandler, params) ->
    payload = {jsonrpc: "2.0", method: method, id: 1, params: params}

    deferred = $q.defer()

    success = (response) ->
      unless response.data
        error response
        return

      if response.data.error
        error response.data.error
        return

      returnData  = resultHandler response.data.result
      total       = if response.data.result.limits then response.data.result.limits.total else null
      deferred.resolve {data: returnData, total: total}
      return

    error = (response) -> 
      console.error "ERROR - #{new Date()}"
      console.error response
      console.error "ERROR ---------------"
      deferred.reject response
      return
        
    $http.post("http://#{kodiRemote.settings.server}:#{kodiRemote.settings.port}/jsonrpc", payload).then(success, error)
    return deferred.promise

  fetch: fetch
]

app.service "SearchService", [ "TvShows", "Movies", (TvShows, Movies) ->
  service =
    tvShows:    []
    movies:     []
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

      TvShows.where.title(query).then (tvShowsData) =>
        @tvShows          = tvShowsData.data
        searchingTvShows  = false
        @searching        = searchingTvShows && searchingMovies

      Movies.where.title(query).then (moviesData) =>
        @movies         = moviesData.data
        searchingMovies = true
        @searching      = searchingTvShows && searchingMovies

      return

  service
]