app = angular.module "kodiRemote.services", []

app.service "Topbar", [->
  service =    
    item: null
    setTitle: (title) -> @item = {type: "title", title: title}
    setLink: (url, label) -> @item = {type: "link", url: url, label: label}

  service
]

app.service "KodiRequest", [ "SERVER", "PORT", "$q", "$http", (SERVER, PORT, $q, $http) ->
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
        
  service
]

app.service "Remote", [ "KodiRequest", (KodiRequest) ->
  service =
    Player:
      activePlayers: -> return KodiRequest.methodRequest "Player.GetActivePlayers", {}
      open: (playlistId, position) -> 
        params = [
          {playlistid: playlistId, position: position}
          {resume: true}
        ]        
        return KodiRequest.methodRequest "Player.Open", params
      stop: -> return KodiRequest.methodRequest "Player.Stop", [1]
    Playlist:
      clear: -> return KodiRequest.methodRequest "Playlist.Clear", [1]
      addEpisode: (episodeId) -> return KodiRequest.methodRequest "Playlist.Add", [1, {episodeid: episodeId}]
      addMovie: (movieId) -> return KodiRequest.methodRequest "Playlist.Add", [1, {movieid: movieId}]
    playEpisode: (episodeId) ->
      @Player.stop().then =>
        @Playlist.clear().then =>
          @Playlist.addEpisode(episodeId).then =>
            @Player.open(1, 0)
    playMovie: (movieId) ->
      @Player.stop().then =>
        @Playlist.clear().then =>
          @Playlist.addMovie(movieId).then =>
            @Player.open(1, 0)

  service
]