app = angular.module "kodiRemote.services", []

app.service "Topbar", [->
  service =
    title: null
    link: null
    addTitle: (title) -> @title = title
    addLink: (url, label) -> @link = {url: url, label: label}
    reset: -> 
      @title = null
      @link = null

  service
]

app.service "Remote", [ "SERVER", "PORT", "$q", "$http", (SERVER, PORT, $q, $http) ->
  request = (payload) ->
    deferred = $q.defer()

    success = (response) ->
      deferred.reject response unless response.data
      deferred.reject response.data.error if response.data.error
      deferred.resolve response.data.result
      return

    error = (response) -> 
      deferred.reject response
      return

    $http.post("http://#{SERVER}:#{PORT}/jsonrpc", payload).then(success, error)

    return deferred.promise

  methodRequest = (method, params = {}) ->
    payload = {jsonrpc: "2.0", method: method, id: 1}
    if params
      payload.params = params
    return request(payload)

  perPage = 10

  service =
    methodRequest: methodRequest

  # service =
  #   videoLibrary:
  #     tvShows:
  #       index: (page = 1) -> 
  #         params =
  #           properties: ["plot", "year", "rating", "genre", "art"]
  #           sort:
  #             order: "ascending"
  #             method: "label"
  #           limits:
  #             start: (page - 1) * perPage
  #             end: page * perPage
  #         return methodRequest "VideoLibrary.GetTVShows", params
  #       show:  (tvShowId) ->
  #         return methodRequest "VideoLibrary.GetTVShowDetails", {tvshowid: tvShowId}
  #       search: (query) ->
  #         params =
  #           properties: ["plot", "year", "rating", "genre", "art"]
  #           filter:
  #             field: "title"
  #             operator: "contains"
  #             value: query
  #         return methodRequest "VideoLibrary.GetTVShows", params
  #       seasons: 
  #         index: (tvShowId) ->
  #           params =
  #             tvshowid: tvShowId
  #           return methodRequest "VideoLibrary.GetSeasons", params
  #         episodes:
  #           index: (tvShowId, seasonId) ->
  #             params =
  #               tvshowid: tvShowId
  #               season: seasonId
  #               properties: ["title", "plot", "rating", "runtime", "art", "thumbnail"]
  #             return methodRequest "VideoLibrary.GetEpisodes", params
  #     movies:
  #       get: ->
  #         params =
  #           properties: ["plot", "year", "rating", "genre", "art", "tagline", "runtime"]
  #           sort:
  #             order: "ascending"
  #             method: "label"
  #           limits:
  #             start: 0
  #             end: 10
  #         return methodRequest "VideoLibrary.GetMovies", params


     
  service
]