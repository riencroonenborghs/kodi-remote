app = angular.module "kodiRemote.remote.services", []

app.service "Remote", [ "KodiRequest", (KodiRequest) ->
  service =
    Player:
      activePlayers: -> return KodiRequest.methodRequest "Player.GetActivePlayers", {}
      playing: (playerId) -> 
        params =
          playerid: playerId
          properties: ["title", "showtitle", "year", "runtime", "season", "episode", "streamdetails"]
        return KodiRequest.methodRequest "Player.GetItem", params
      open: (playlistId, position) -> 
        params = [
          {playlistid: playlistId, position: position}
          {resume: true}
        ]        
        return KodiRequest.methodRequest "Player.Open", params
      stop: -> return KodiRequest.methodRequest "Player.Stop", [1]
      playPause: (playerId) -> return KodiRequest.methodRequest "Player.PlayPause", [playerId]
      properties: (playerId) -> return KodiRequest.methodRequest "Player.GetProperties", params = [playerId, ["percentage", "time", "subtitles", "audiostreams", "subtitleenabled"]]
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

app.service "RemoteControl", [ "KodiRequest", (KodiRequest) ->
  service =    
    up: -> return KodiRequest.methodRequest "Input.Up", {}
    down: -> return KodiRequest.methodRequest "Input.Down", {}
    left: -> return KodiRequest.methodRequest "Input.Left", {}
    right: -> return KodiRequest.methodRequest "Input.Right", {}
    home: -> return KodiRequest.methodRequest "Input.Home", {}
    select: -> return KodiRequest.methodRequest "Input.Select", {}
    back: -> return KodiRequest.methodRequest "Input.Back", {}
    scanLibrary: -> return KodiRequest.methodRequest "VideoLibrary.Scan", {}
    info: -> return KodiRequest.methodRequest "Input.Info", {}
    clean: -> return KodiRequest.methodRequest "VideoLibrary.Clean", {}
]