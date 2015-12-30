app = angular.module "kodiRemote.controllers", []

app.controller "AppController", [ "$scope", "$rootScope", "$interval", "$timeout", "$location", "$mdSidenav", "$mdToast", "SearchService","Player",
($scope, $rootScope, $interval, $timeout, $location, $mdSidenav, $mdToast, SearchService, Player) ->

  # chrome.storage.local.clear()

  $scope.loading = true
  $scope.$on "topbar.loading", (event, value) ->
    $scope.loading = value

  # visits
  $scope.visit = (path) ->
    $scope.showSearch = false
    $location.path path
  $scope.visitSeasons         = (tvShowId) -> $scope.visit "/tvshows/#{tvShowId}/seasons"
  $scope.visitEpisodes        = (tvShowId, seasonId) -> $scope.visit "/tvshows/#{tvShowId}/seasons/#{seasonId}/episodes"
  $scope.visitEpisode         = (episodeId) -> $scope.visit "/episodes/#{episodeId}"
  $scope.visitMovie           = (movieId) -> $scope.visit "/movies/#{movieId}"
  $scope.visitGenres          = (type) -> $scope.visit "#{type}/genres"
  $scope.visitGenre           = (type, genre) -> 
    console.debug "visitGenre"
    console.debug "/genres/#{type}/#{genre}" 
    $scope.visit "/genres/#{type}/#{genre}"
  $scope.visitRecentlyAdded   = (type) -> $scope.visit "/#{type}/recently-added"
  $scope.visitYears           = -> $scope.visit "/movies/years"
  $scope.visitYear            = (year) -> $scope.visit "/movies/years/#{year}"
  $scope.visitRating          = (type) -> $scope.visit "#{type}/rating"

  # init the app
  # search, location changes, remote, what's playing interval
  initApp = ->
    
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

    $scope.openPlaylist = -> 
      $rootScope.$broadcast "playlist.reload"
      $mdSidenav("playlist").toggle()

    $scope.$on "show.message", (event, message) ->
      $mdToast.show
        controller: "MessageController"
        templateUrl: "app/views/ui/message.html"
        hideDelay: 2000
        position: "bottom right"
        locals:
          message: message

    # what is playing now?
    $scope.playingNowVisible = false
    $scope.playing = null
    $scope.playerId = null

    whatsPlaying = ->    
      Player.activePlayers().then (data) ->   
        data = data.data
        if data.length > 0
          $scope.playerId = data[0].playerid
          Player.playing($scope.playerId).then (data) ->
            $scope.playing = data.data.item
            $scope.playingNowVisible = true
        else
          $scope.playing = null
          $scope.playingNowVisible = false
    whatsPlaying()
    $interval whatsPlaying, 1000


  # check for settings (server + port) in interval
  # if not found go to settings page and keep checking
  # if found init the app and cancel check
  checkServer = ->
    $scope.hasServer = false
    unless kodiRemote.settings.server != null && kodiRemote.settings.port != null && kodiRemote.settings.requestType
      return
    Player.activePlayers().then (data) ->
      $scope.hasServer = true
  checkServer()

  loadSettings = ->
    chrome.storage.local.get "kodiRemote", (data) ->
      if data.kodiRemote
        parsedData = JSON.parse data.kodiRemote
        kodiRemote.settings.server      = parsedData.server
        kodiRemote.settings.port        = parsedData.port
        kodiRemote.settings.requestType = parsedData.requestType
        # it's set, no check if we can access the server
        # if so, init the app and go to tv shows
        checkServer()        
        $timeout (->
          if $scope.hasServer
            $interval.cancel loadSettingsInterval
            initApp()
            $location.path "/tvshows"
        ), 500

  loadSettingsInterval = $interval loadSettings, 1000
  loadSettings()
  
  if $scope.hasServer
    initApp()
  else
    $location.path "/settings"
    return      
]

app.controller "MessageController", [ "$scope", "message", ($scope, message) ->
  $scope.message = message
]