app = angular.module "kodiRemote.controllers", []

app.controller "AppController", [ "$scope", "$interval", "$timeout", "$location", "SearchService", "Topbar", "Remote",
($scope, $interval, $timeout, $location, SearchService, Topbar, Remote) ->

  # chrome.storage.local.clear()

  # init the app
  # search, location changes, remote, what's playing interval
  initApp = ->
    $scope.Topbar = Topbar

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
    $scope.visit = (path) ->
      $scope.showSearch = false
      $location.path path
    $scope.visitSeasons = (tvShowId) -> $scope.visit("/tvshows/#{tvShowId}/seasons")

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
            # console.debug data
            $scope.playing = data.item
            $scope.remoteVisible = true
        else
          $scope.playing = null
          $scope.remoteVisible = false
    whatsPlaying()
    $interval whatsPlaying, 1000

    $scope.keyPressed = (event) ->
      console.debug event


  # check for settings (server + port) in interval
  # if not found go to settings page and keep checking
  # if found init the app and cancel check
  $scope.hasServer = kodiRemote.settings.server != null && kodiRemote.settings.port != null
  loadSettings = ->
    chrome.storage.local.get "kodiRemote", (data) ->
      if data.kodiRemote
        parsedData = JSON.parse data.kodiRemote
        kodiRemote.settings.server  = parsedData.server
        kodiRemote.settings.port    = parsedData.port
        $scope.hasServer = kodiRemote.settings.server != null && kodiRemote.settings.port != null
        initApp()
        $location.path "/tvshows"

    if $scope.hasServer
      $interval.cancel loadSettingsInterval
      return
  loadSettingsInterval = $interval loadSettings, 1000
  loadSettings()
  
  if $scope.hasServer
    initApp()
  else
    $location.path "/settings"
    return      
]

app.controller "PlayingRemoteController", [ "$scope", "$interval", "Remote", ($scope, $interval, Remote) ->
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

# app.controller "PaginatedController", [ "$scope", ($scope) ->
#   # $scope.listService        = service that loads the paginated list
#   # $scope.pushItemsOntoList  = method that handles adding the items onto the list

#   $scope.loading          = false
#   $scope.list             = []
#   $scope.page             = 1
#   $scope.morePages        = true  

#   $scope.nextPage = ->
#     $scope.page += 1
#     $scope.loadCurrentPage()

#   $scope.loadCurrentPage = ->
#     $scope.loading = true
#     $scope.listService.index($scope.page).then (data) ->
#       $scope.pushItemsOntoList data
#       $scope.loading    = false
#       totalItemsInList  = data.limits.total
#       $scope.morePages  = ($scope.page * $scope.listService.perPage) < totalItemsInList      
#       return

#   $scope.loadCurrentPage()
# ]

app.controller "SortedPaginatedController", [ "$scope", ($scope) ->
  # $scope.listService        = service that loads the paginated list
  # $scope.pushItemsOntoList  = method that handles adding the items onto the list

  # sorting
  $scope.sort = 
    by: 
      labels: ["Name", "Recent"]
      methods: ["label", "dateadded"]
      current: 0
    direction:
      icons: ["sort_ascending", "sort_descending"]
      methods: ["ascending", "descending"]
      current: 0
  
  $scope.toggleSortDirection = ->
    $scope.sort.direction.current += 1
    $scope.sort.direction.current = 0 if $scope.sort.direction.current == $scope.sort.direction.methods.length
    $scope.list = []
    $scope.page = 1
    $scope.loadCurrentPage()

  $scope.toggleSortBy = -> 
    $scope.sort.by.current += 1
    $scope.sort.by.current = 0 if $scope.sort.by.current == $scope.sort.by.methods.length
    $scope.list = []
    $scope.page = 1
    $scope.loadCurrentPage()

  # pagination
  $scope.loading          = false
  $scope.list             = []
  $scope.page             = 1
  $scope.morePages        = true  

  $scope.nextPage = ->
    $scope.page += 1
    $scope.loadCurrentPage()

  $scope.loadCurrentPage = ->
    $scope.loading = true
    $scope.listService.index($scope.page, $scope.sort.by.methods[$scope.sort.by.current], $scope.sort.direction.methods[$scope.sort.direction.current]).then (data) ->
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
      $scope.listService.Search.query($scope.search.query).then (data) ->
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