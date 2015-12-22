app = angular.module "kodiRemote.tvshows.controllers", []

kodiRemote.array =
  inGroupsOf: (_list, number) ->
    list = _list.slice(0)
    newList = []
    while list.length > 0
      newList.push list.splice(0, number)
    return newList

app.controller "TvShowsController", [ "$scope", "$rootScope", "NavbarFactory", "TvShows", ($scope, $rootScope, NavbarFactory, TvShows) ->  
  $scope.tvShows = []  
  $scope.tvShowGroups = []

  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad  before load

  $scope.beforeSortLoad = ->
    $scope.tvShows = []
    $scope.pagination.page = 1

  # autoScrollPaginate directive
  # - sets $scope.pagination hash
  # - uses $scope.paginationAfterLoad to calculate $scope.pagination.more

  $scope.load = ->
    $rootScope.$broadcast "topbar.loading", true
    TvShows.all($scope.pagination.page, $scope.sortParams).then (data) ->
      $rootScope.$broadcast "topbar.loading", false
      for tvShow in data.data
        $scope.tvShows.push tvShow

      $scope.tvShowGroups = kodiRemote.array.inGroupsOf $scope.tvShows, 2      

      $scope.Navbar = new NavbarFactory
      $scope.Navbar.addTitle "TV Shows (#{data.total})"
      $scope.paginationAfterLoad TvShows.perPage, data.total
      return
]

app.controller "SeasonsController", [ "$scope", "$rootScope", "$routeParams", "NavbarFactory", "TvShows", 
($scope, $rootScope, $routeParams, NavbarFactory, TvShows) ->  
  tvShowId = parseInt $routeParams.id

  $scope.tvShow = null
  $scope.seasons = []
  $scope.seasonGroups = []

  $rootScope.$broadcast "topbar.loading", true
  TvShows.get(tvShowId).then (tvShowData) ->
    $rootScope.$broadcast "topbar.loading", false
    $scope.tvShow = tvShowData.data    
    $scope.Navbar = new NavbarFactory
    $scope.Navbar.addLink "/tvshows", "TV Shows"
    $scope.Navbar.addTitle $scope.tvShow.title
    $scope.tvShow.seasons().then (seasonsData) ->
      $scope.seasons = seasonsData.data
      $scope.seasonGroups = kodiRemote.array.inGroupsOf $scope.seasons, 2
]


app.controller "EpisodesController", [ "$scope", "$rootScope", "$routeParams", "NavbarFactory", "TvShows",
($scope, $rootScope, $routeParams, NavbarFactory, TvShows) ->  
  tvShowId = parseInt $routeParams.tvshowid  
  seasonId = parseInt $routeParams.id

  $scope.tvShow = null
  $scope.season = null
  $scope.episodes = []
  $scope.episodeGroups = []

  $rootScope.$broadcast "topbar.loading", true
  TvShows.get(tvShowId).then (tvShowData) ->
    $scope.tvShow = tvShowData.data
    $scope.tvShow.seasons().then (seasonsData) ->
      for season in seasonsData.data
        if season.seasonid == seasonId || season.season == seasonId
          $scope.season = season
          $scope.Navbar = new NavbarFactory
          $scope.Navbar.addLink "/tvshows", "TV Shows"
          $scope.Navbar.addLink "/tvshows/#{tvShowId}/seasons", $scope.tvShow.title
          $scope.Navbar.addTitle "Season #{season.season}"
          season.episodes().then (episodeData) ->
            $rootScope.$broadcast "topbar.loading", false
            $scope.episodes = episodeData.data
            $scope.episodeGroups = kodiRemote.array.inGroupsOf $scope.episodes, 2
]

app.controller "EpisodeController", [ "$scope", "$rootScope", "$routeParams", "Episodes", "NavbarFactory",
($scope, $rootScope, $routeParams, Episodes, NavbarFactory) ->
  episodeId = parseInt $routeParams.id

  $scope.episode = null  

  $rootScope.$broadcast "topbar.loading", true
  Episodes.get(episodeId).then (episodeData) ->
    $rootScope.$broadcast "topbar.loading", false
    $scope.episode = episodeData.data
    $scope.Navbar = new NavbarFactory
    $scope.Navbar.addLink "/tvshows", "TV Shows"
    $scope.Navbar.addLink "/tvshows/#{$scope.episode.tvshowid}/seasons", $scope.episode.showtitle
    $scope.Navbar.addLink "/tvshows/#{$scope.episode.tvshowid}/seasons/#{$scope.episode.season}/episodes", "Season #{$scope.episode.season}"
    $scope.Navbar.addTitle "Episode #{$scope.episode.episode}: #{$scope.episode.title}"
]