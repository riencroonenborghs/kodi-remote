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

app.service "Remote", [ "KodiRequest", (KodiRequest) ->
  service =
    Player:
      activePlayers: -> return KodiRequest.methodRequest "Player.GetActivePlayers", {}
      playing: (playerId) -> 
        params =
          playerid: playerId
          properties: ["title", "showtitle", "year", "runtime", "season", "episode"]
          # properties: ["title", "artist", "albumartist", "genre", "year", "rating", "album", "track", "duration", "comment", "lyrics", "musicbrainztrackid", "musicbrainzartistid", "musicbrainzalbumid", "musicbrainzalbumartistid", "playcount", "fanart", "director", "trailer", "tagline", "plot", "plotoutline", "originaltitle", "lastplayed", "writer", "studio", "mpaa", "cast", "country", "imdbnumber", "premiered", "productioncode", "runtime", "set", "showlink", "streamdetails", "top250", "votes", "firstaired", "season", "episode", "showtitle", "thumbnail", "file", "resume", "artistid", "albumid", "tvshowid", "setid", "watchedepisodes", "disc", "tag", "art", "genreid", "displayartist", "albumartistid", "description", "theme", "mood", "style", "albumlabel", "sorttitle", "episodeguide", "uniqueid", "dateadded", "channel", "channeltype", "hidden", "locked", "channelnumber", "starttime", "endtime"]
        return KodiRequest.methodRequest "Player.GetItem", params
      open: (playlistId, position) -> 
        params = [
          {playlistid: playlistId, position: position}
          {resume: true}
        ]        
        return KodiRequest.methodRequest "Player.Open", params
      stop: -> return KodiRequest.methodRequest "Player.Stop", [1]
      playPause: (playerId) -> return KodiRequest.methodRequest "Player.PlayPause", [playerId]
      properties: (playerId) -> return KodiRequest.methodRequest "Player.GetProperties", params = [playerId, ["percentage", "time", "subtitles", "audiostreams"]]
      setSubtitle: (playerId, subtitle) -> return KodiRequest.methodRequest "Player.SetSubtitle", params = [playerId, subtitle]
      setAudioStream: (playerId, audiostream) -> return KodiRequest.methodRequest "Player.SetAudioStream", params = [playerId, audiostream]
      seek: (playerId, percentage) ->  return KodiRequest.methodRequest "Player.Seek", params = [playerId, percentage]
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


app.service "SearchService", [ "TvShows", "Movies", (TvShows, Movies) ->
  service =
    tvShows: []
    movies: []
    searching: false

    reset: -> 
      @tvShows = []
      @movies = []
      @searching = false
    search: (query) ->
      return unless query.length > 2

      searchingTvShows  = true
      searchingMovies   = true
      @searching        = searchingTvShows && searchingMovies

      TvShows.search(query).then (data) =>
        @tvShows          = data.tvshows
        searchingTvShows  = false
        @searching        = searchingTvShows && searchingMovies

      Movies.search(query).then (data) =>
        @movies         = data.movies
        searchingMovies = true
        @searching      = searchingTvShows && searchingMovies

      return

  service
]