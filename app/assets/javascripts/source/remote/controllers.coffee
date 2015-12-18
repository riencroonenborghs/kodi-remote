app = angular.module "kodiRemote.remote.controllers", []

app.controller "PlayingNowRemoteController", [ "$scope", "$interval", "Remote", ($scope, $interval, Remote) ->
  $scope.stop = -> Remote.Player.stop()

  $scope.playPauseState = false
  $scope.playPause = -> 
    Remote.Player.playPause($scope.playerId).then (data) ->
      $scope.playPauseState = !$scope.playPauseState

  $scope.fastForward = ->
    Remote.Player.seek $scope.playerId, $scope.percentage + 1
  $scope.rewind = ->
    Remote.Player.seek $scope.playerId, $scope.percentage - 1

  $scope.subtitles =
    enabled: false
    available: []
    valid: ["on", "next", "off"]
    current: 0  
  $scope.switchSubtitle = -> 
    subtitle = $scope.subtitles.valid[$scope.subtitles.current]
    Remote.Player.setSubtitle $scope.playerId, subtitle
    $scope.subtitles.current += 1
    $scope.subtitles.current = 0 if $scope.subtitles.current == $scope.subtitles.valid.length

  $scope.audioStreams =
    valid: ["next", "previous"]
    current: 0
    available: []
  $scope.switchAudioStream = ->
    audioStream = $scope.audioStreams.valid[$scope.audioStreams.current]
    Remote.Player.setAudioStream $scope.playerId, audioStream
    $scope.audioStreams.current += 1
    $scope.audioStreams.current = 0 if $scope.audioStreams.current == $scope.audioStreams.valid.length

  $scope.percentage = 0
  $scope.timeElapsed = 0
  $scope.timeRemaining = 0
  getProperties = ->
    if $scope.playing
      Remote.Player.properties($scope.playerId).then (data) ->        
        $scope.percentage             = data.percentage
        $scope.timeElapsed            = data.time
        $scope.subtitles.available    = data.subtitles
        $scope.subtitles.enabled      = data.subtitleenabled
        $scope.audioStreams.available = data.audiostreams

        timeElapsedInSeconds = data.time.hours * 3600 + data.time.minutes * 60 + data.time.seconds
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
    Remote.Player.seek $scope.playerId, $scope.percentage
]

app.controller "RemoteController", [ "$scope", "RemoteControl", ($scope, RemoteControl) ->
  $scope.up = -> RemoteControl.up()
  $scope.down = -> RemoteControl.down()
  $scope.left = -> RemoteControl.left()
  $scope.right = -> RemoteControl.right()
  $scope.home = -> RemoteControl.home()
  $scope.enter = -> RemoteControl.select()
  $scope.back = -> RemoteControl.back()
  $scope.refresh = -> RemoteControl.scanLibrary()
  $scope.info = -> RemoteControl.info()
  $scope.clean = -> RemoteControl.clean()
]