app = angular.module "kodiRemote.remote.services", []

app.service "Player", [ "$rootScope", "Request", "Playlist", ($rootScope, Request, Playlist) ->
  emptyHandler = (data) -> return

  returnHandler = (data) -> return data

  service =
    activePlayers: ->
      return Request.fetch "Player.GetActivePlayers", returnHandler, {}
    playing: (playerId) -> 
      params =
        playerid: playerId
        properties: ["title", "showtitle", "year", "runtime", "season", "episode", "streamdetails"]
      return Request.fetch "Player.GetItem", returnHandler, params
    open: (playlistId, position) -> 
      $rootScope.$broadcast "playlist.reload"
      params = [
        {playlistid: playlistId, position: position}
        {resume: true}
      ]        
      return Request.fetch "Player.Open", emptyHandler, params
    stop: -> return Request.fetch "Player.Stop", emptyHandler, [1]
    playPause: (playerId) -> return Request.fetch "Player.PlayPause", emptyHandler, [playerId]
    properties: (playerId) -> return Request.fetch "Player.GetProperties", returnHandler, [playerId, ["percentage", "time", "subtitles", "audiostreams", "subtitleenabled"]]
    setSubtitle: (playerId, subtitle) -> return Request.fetch "Player.SetSubtitle", emptyHandler, [playerId, subtitle]
    setAudioStream: (playerId, audiostream) -> return Request.fetch "Player.SetAudioStream", emptyHandler, [playerId, audiostream]
    seek: (playerId, percentage) ->  return Request.fetch "Player.Seek", emptyHandler, [playerId, percentage]
    playEpisode: (episodeId) ->
      @stop().then =>
        Playlist.clear().then =>
          Playlist.addEpisode(episodeId).then =>
            @open(1, 0)
    playMovie: (movieId) ->
      @stop().then =>
        Playlist.clear().then =>
          Playlist.addMovie(movieId).then =>
            @open(1, 0)  
  service
]

app.service "Remote", [ "Request", (Request) ->
  emptyHandler = (data) -> return

  service =    
    up: -> return Request.fetch "Input.Up", emptyHandler, {}
    down: -> return Request.fetch "Input.Down", emptyHandler, {}
    left: -> return Request.fetch "Input.Left", emptyHandler, {}
    right: -> return Request.fetch "Input.Right", emptyHandler, {}
    home: -> return Request.fetch "Input.Home", emptyHandler, {}
    select: -> return Request.fetch "Input.Select", emptyHandler, {}
    back: -> return Request.fetch "Input.Back", emptyHandler, {}
    scanLibrary: -> return Request.fetch "VideoLibrary.Scan", emptyHandler, {}
    info: -> return Request.fetch "Input.Info", emptyHandler, {}
    clean: -> return Request.fetch "VideoLibrary.Clean", emptyHandler, {}

  service
]