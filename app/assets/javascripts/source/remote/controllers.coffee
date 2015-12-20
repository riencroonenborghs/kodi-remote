app = angular.module "kodiRemote.remote.controllers", []

app.controller "PlayingNowRemoteController", [ "$scope", "$interval", "Player", ($scope, $interval, Player) ->
  $scope.stop = -> Player.stop()

  $scope.playPauseState = false
  $scope.playPause = -> 
    Player.playPause($scope.playerId).then (data) ->
      $scope.playPauseState = !$scope.playPauseState

  $scope.fastForward = ->
    Player.seek $scope.playerId, $scope.percentage + 1
  $scope.rewind = ->
    Player.seek $scope.playerId, $scope.percentage - 1

  $scope.subtitles =
    enabled: false
    available: []
    valid: ["on", "next", "off"]
    current: 0  
  $scope.switchSubtitle = -> 
    subtitle = $scope.subtitles.valid[$scope.subtitles.current]
    Player.setSubtitle $scope.playerId, subtitle
    $scope.subtitles.current += 1
    $scope.subtitles.current = 0 if $scope.subtitles.current == $scope.subtitles.valid.length

  $scope.audioStreams =
    valid: ["next", "previous"]
    current: 0
    available: []
  $scope.switchAudioStream = ->
    audioStream = $scope.audioStreams.valid[$scope.audioStreams.current]
    Player.setAudioStream $scope.playerId, audioStream
    $scope.audioStreams.current += 1
    $scope.audioStreams.current = 0 if $scope.audioStreams.current == $scope.audioStreams.valid.length

  $scope.percentage = 0
  $scope.timeElapsed = 0
  $scope.timeRemaining = 0
  getProperties = ->
    if $scope.playing
      Player.properties($scope.playerId).then (data) ->              
        $scope.percentage             = data.data.percentage
        $scope.timeElapsed            = data.data.time
        $scope.subtitles.available    = data.data.subtitles
        $scope.subtitles.enabled      = data.data.subtitleenabled
        $scope.audioStreams.available = data.data.audiostreams

        timeElapsedInSeconds = data.data.time.hours * 3600 + data.data.time.minutes * 60 + data.data.time.seconds
        seconds = $scope.playing.runtime - timeElapsedInSeconds
        hours   = Math.floor(seconds / 3600)
        minutes = Math.floor((seconds - (hours * 3600)) / 60)
        seconds = Math.floor((seconds - (hours * 3600)) % 60)
        $scope.timeRemaining =
          hours: hours
          minutes: minutes
          seconds: seconds

  $interval getProperties, 1000

  $scope.jumpTo = ->
    Player.seek $scope.playerId, $scope.percentage
]

app.controller "RemoteController", [ "$scope", "Remote", ($scope, Remote) ->
  $scope.up = -> Remote.up()
  $scope.down = -> Remote.down()
  $scope.left = -> Remote.left()
  $scope.right = -> Remote.right()
  $scope.home = -> Remote.home()
  $scope.enter = -> Remote.select()
  $scope.back = -> Remote.back()
  $scope.refresh = -> Remote.scanLibrary()
  $scope.info = -> Remote.info()
  $scope.clean = -> Remote.clean()
]