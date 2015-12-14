app = angular.module "kodiRemote.controllers", []

app.controller "AppController", [ "$scope", "$interval", "$timeout", "$location", "SearchService", "Topbar", "Remote",
($scope, $interval, $timeout, $location, SearchService, Topbar, Remote) ->
  $scope.Topbar = Topbar
  Topbar.setTitle "Kodi Remote"

  # search
  $scope.toggleSearch   = -> 
    $scope.showSearch = !$scope.showSearch
    $scope.search.query = ""
    $scope.searchService.reset()
    if $scope.showSearch
      $timeout (-> $("#search-query").focus()), 500
  $scope.showSearch     = false
  $scope.search         = {query: ""}
  $scope.searchService  = SearchService
  $scope.performSearch  = -> $scope.searchService.search $scope.search.query

  # visits
  $scope.visit = (path) -> $location.path path
  $scope.visitSeasons = (tvShowId) -> 
    console.debug "visitSeasons #{tvShowId}"
    $scope.visit("/tvshows/#{tvShowId}/seasons")

  # remote
  $scope.remoteVisible = false

  # what is playing
  $scope.playing = null
  $scope.playerId = null

  whatsPlaying = ->    
    Remote.Player.activePlayers().then (data) ->      
      if data.length > 0
        $scope.playerId = data[0].playerid
        Remote.Player.playing($scope.playerId).then (data) ->
          $scope.playing = data.item
          $scope.remoteVisible = true
      else
        $scope.playing = null
        $scope.remoteVisible = false
  whatsPlaying()
  $interval whatsPlaying, 1000
]

app.controller "RemoteController", [ "$scope", "$interval", "Remote", ($scope, $interval, Remote) ->
  $scope.stop = -> Remote.Player.stop()

  $scope.playPauseState = false
  $scope.playPause = -> 
    Remote.Player.playPause($scope.playerId).then (data) ->
      $scope.playPauseState = !$scope.playPauseState

  $scope.fastForward = ->
    Remote.Player.seek $scope.playerId, $scope.percentage + 1
  $scope.rewind = ->
    Remote.Player.seek $scope.playerId, $scope.percentage - 1

  availableSubtitles  = ["on", "next", "off"]
  currentSubtitle     = 0
  $scope.subtitles    = []
  $scope.switchSubtitle = -> 
    subtitle = availableSubtitles[currentSubtitle]
    Remote.Player.setSubtitle $scope.playerId, subtitle
    currentSubtitle += 1
    currentSubtitle = 0 if currentSubtitle == availableSubtitles.length

  availableAudioStreams = ["next", "previous"]
  currentAudioStreams   = 0
  $scope.audioStreams   = []  
  $scope.switchAudioStream = ->
    audioStream = availableAudioStreams[currentAudioStream]
    Remote.Player.setAudioStream $scope.playerId, audioStream
    currentAudioStream = 0 if currentAudioStream == availableAudioStreams.length

  $scope.percentage = 0
  $scope.timeElapsed = 0
  $scope.timeRemaining = 0
  getProperties = ->
    if $scope.playing
      Remote.Player.properties($scope.playerId).then (data) ->
        # console.debug data
        $scope.percentage = data.percentage
        $scope.timeElapsed = data.time
        $scope.subtitles = data.subtitles
        $scope.audioStreams = data.audiostreams

        timeElapsedInSeconds = data.time.hours * 3600 + data.time.minutes * 60 + data.time.seconds

        seconds = $scope.playing.runtime - timeElapsedInSeconds
        hours = Math.floor(seconds / 3600)
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

app.controller "PaginatedController", [ "$scope", ($scope) ->
  # $scope.listService        = service that loads the paginated list
  # $scope.pushItemsOntoList  = method that handles adding the items onto the list

  $scope.loading          = false
  $scope.list             = []
  $scope.page             = 1
  $scope.morePages        = true  

  $scope.nextPage = ->
    $scope.page += 1
    $scope.loadCurrentPage()

  $scope.loadCurrentPage = ->
    $scope.loading = true
    $scope.listService.index($scope.page).then (data) ->
      $scope.pushItemsOntoList data
      $scope.loading    = false
      totalItemsInList  = data.limits.total
      $scope.morePages  = ($scope.page * $scope.listService.perPage) < totalItemsInList      
      return

  $scope.loadCurrentPage()
]

app.controller "SearchController", [ "$scope", ($scope) ->
  # $scope.listService    = service that performs the search
  # $scope.setItemsOnList = pushes data onto list
  # $scope.emptyList      = clears the list

  $scope.search = {query: ""}

  $scope.performSearch = ->    
    if $scope.search.query.length > 2
      $scope.loading = true
      $scope.listService.search($scope.search.query).then (data) ->
        $scope.setItemsOnList data
        $scope.morePages  = false
        $scope.loading    = false
        return
    else
      $scope.emptyList()
      $scope.page       = 1
      $scope.morePages  = true
      $scope.loadCurrentPage()
]