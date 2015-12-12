app = angular.module "kodiRemote.tvshows.controllers", []

app.controller "TvShowsController", [ "$scope", "$controller", "Topbar", "TvShows", ($scope, $controller, Topbar, TvShows) ->
  Topbar.reset()
  Topbar.addTitle "TV Shows"

  $scope.listService = TvShows
  $scope.pushItemsOntoList = (data) ->
    for tvShow in data.tvshows
      $scope.list.push tvShow
    Topbar.addTitle "TV Shows (#{data.limits.total})"
  $controller "PaginatedController", {$scope: $scope}

  $scope.setItemsOnList = (data) -> $scope.list = data.tvshows
  $scope.emptyList = -> $scope.list = []
  $controller "SearchController", {$scope: $scope}

  $scope.visitSeasons = (tvShowId) -> $scope.visit("/tvshows/#{tvShowId}/seasons")
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
  
  $scope.$watch "seasonNumber", ->
    if $scope.seasonNumber
      Remote.videoLibrary.tvShows.seasons.episodes.index($scope.tvShowId, $scope.seasonNumber).then (data) -> 
        $scope.loading = false
        $scope.episodes = data.episodes
        return
]