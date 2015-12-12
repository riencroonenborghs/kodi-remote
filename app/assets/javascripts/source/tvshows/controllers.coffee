app = angular.module "kodiRemote.tvshows.controllers", []

app.controller "TvShowsController", [ "$scope", "Topbar", "Remote", ($scope, Topbar, Remote) ->
  Topbar.reset()
  Topbar.addTitle "TV Shows"

  $scope.search = {query: ""}
  $scope.tvShows = []
  $scope.morePages = true
  page = 1
  total = 0

  $scope.visitSeasons = (tvShowId) ->
    $scope.visit("/tvshows/#{tvShowId}/seasons")
  
  $scope.nextPage = ->     
    page += 1    
    loadPage()

  loadPage = ->    
    $scope.loading = true    
    Remote.videoLibrary.tvShows.index(page).then (data) -> 
      $scope.loading = false            
      for tvShow in data.tvshows
        $scope.tvShows.push tvShow   
      total = data.limits.total   
      $scope.morePages = (page * 10) < total
      Topbar.addTitle "TV Shows (#{data.limits.total})"
      return

  loadPage()

  $scope.searchTVShows = ->    
    if $scope.search.query.length > 2
      $scope.loading = true
      Remote.videoLibrary.tvShows.search($scope.search.query).then (data) ->
        $scope.morePages = false
        $scope.loading = false
        $scope.tvShows = data.tvshows
        return
    else
      page = 1
      $scope.morePages = true
      $scope.tvShows = []
      loadPage()
]

app.controller "TvShowSeasonsController", [ "$scope", "$routeParams", "Topbar", "Remote", 
($scope, $routeParams, Topbar, Remote) ->  
  $scope.tvShowId = parseInt $routeParams.id

  $scope.visitEpisodes = (tvShowId, seasonId) ->
    $scope.visit("/tvshows/#{tvShowId}/seasons/#{seasonId}/episodes")

  Remote.videoLibrary.tvShows.show($scope.tvShowId).then (data) -> 
    $scope.tvShowDetails = data.tvshowdetails
    Topbar.reset()
    Topbar.addLink "/tvshows", data.tvshowdetails.label

  $scope.loading = true
  $scope.seasons = []
  Remote.videoLibrary.tvShows.seasons.index($scope.tvShowId).then (data) -> 
    $scope.loading = false
    $scope.seasons = data.seasons
    return
]

app.controller "TvShowSeasonEpisodesController", [ "$scope", "$routeParams", "Topbar", "Remote", 
($scope, $routeParams, Topbar, Remote) ->  
  $scope.tvShowId = parseInt $routeParams.tvshowid  
  $scope.seasonId = parseInt $routeParams.id

  $scope.tvShowDetails = null
  $scope.episodes = []
  $scope.seasonNumber = null
  $scope.loading = true

  Remote.videoLibrary.tvShows.show($scope.tvShowId).then (data) ->
    $scope.tvShowDetails = data.tvshowdetails

  Remote.videoLibrary.tvShows.seasons.index($scope.tvShowId).then (data) -> 
    for season, index in data.seasons      
      if season.seasonid == $scope.seasonId
        $scope.seasonNumber = index + 1
        Topbar.reset()
        Topbar.addLink "/tvshows/#{$scope.tvShowId}/seasons", season.label
  
  $scope.$watch "seasonNumber", (current, old) ->    
    console.debug current
    if current
      Remote.videoLibrary.tvShows.seasons.episodes.index($scope.tvShowId, $scope.seasonNumber).then (data) -> 
        $scope.loading = false
        $scope.episodes = data.episodes
        return
]