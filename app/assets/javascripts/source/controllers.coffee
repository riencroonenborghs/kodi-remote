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
    $scope.visitSeasons   = (tvShowId) -> $location.path "/tvshows/#{tvShowId}/seasons"
    $scope.visitEpisodes  = (tvShowId, seasonId) -> $location.path "/tvshows/#{tvShowId}/seasons/#{seasonId}/episodes"
    $scope.visitMovie     = (movieId) -> $location.path "/movies/#{movieId}"

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
    # $interval whatsPlaying, 1000

    # $scope.keyPressed = (event) ->
    #   console.debug event


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

