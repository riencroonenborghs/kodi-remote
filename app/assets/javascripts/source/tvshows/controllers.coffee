app = angular.module "kodiRemote.tvshows.controllers", []

app.controller "TvShowsController", [ "$scope", "Topbar", "TvShows", ($scope, Topbar, TvShows) ->  
  Topbar.setTitle "TV Shows"

  $scope.tvShows = []

  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad  before load

  $scope.beforeSortLoad = ->
    $scope.tvShows = []
    $scope.pagination.page = 1

  # autoScrollPaginate directive
  # - sets $scope.pagination hash
  # - uses $scope.paginationAfterLoad to calculate $scope.pagination.more
  # - uses $scope.loading

  $scope.load = ->
    $scope.loading = true
    TvShows.all($scope.pagination.page, $scope.sortParams).then (data) ->
      $scope.loading = false
      for tvShow in data.data
        $scope.tvShows.push tvShow
      Topbar.setTitle "TV Shows (#{data.total})"
      $scope.paginationAfterLoad TvShows.perPage, data.total
      return
]

app.controller "SeasonsController", [ "$scope", "$routeParams", "Topbar", "TvShows", 
($scope, $routeParams, Topbar, TvShows) ->  
  tvShowId = parseInt $routeParams.id

  $scope.tvShow = null
  $scope.seasons = []

  TvShows.get(tvShowId).then (tvShowData) ->
    $scope.tvShow = tvShowData.data
    Topbar.setLink "/tvshows", $scope.tvShow.title
    $scope.tvShow.seasons().then (seasonsData) ->
      $scope.seasons = seasonsData.data
]


app.controller "EpisodesController", [ "$scope", "$routeParams", "Topbar", "TvShows", "Remote",
($scope, $routeParams, Topbar, TvShows, Remote) ->  
  tvShowId = parseInt $routeParams.tvshowid  
  seasonId = parseInt $routeParams.id

  $scope.tvShow = null
  $scope.season = null
  $scope.episodes = []

  TvShows.get(tvShowId).then (tvShowData) ->
    $scope.tvShow = tvShowData.data
    $scope.tvShow.seasons().then (seasonsData) ->
      for season in seasonsData.data
        if season.seasonid == seasonId
          $scope.season = season
          Topbar.setLink "/tvshows/#{$scope.tvShow.tvshowid}/seasons", "Season #{season.season}"
          season.episodes().then (episodeData) ->
            $scope.episodes = episodeData.data

  $scope.play = (episode) -> Remote.playEpisode(episode.episodeid)
]