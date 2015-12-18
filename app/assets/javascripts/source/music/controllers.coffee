app = angular.module "kodiRemote.music.controllers", []

app.controller "AlbumsController", [ "$scope", "NavbarFactory", "Albums", ($scope, NavbarFactory, Albums) ->  
  $scope.albums = []  

  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad  before load

  $scope.beforeSortLoad = ->
    $scope.albums = []
    $scope.pagination.page = 1

  # autoScrollPaginate directive
  # - sets $scope.pagination hash
  # - uses $scope.paginationAfterLoad to calculate $scope.pagination.more
  # - uses $scope.loading

  $scope.load = ->
    $scope.loading = true
    Albums.all($scope.pagination.page, $scope.sortParams).then (data) ->      
      $scope.loading = false
      for album in data.data
        $scope.albums.push album
      $scope.Navbar = new NavbarFactory
      $scope.Navbar.addTitle "Albums (#{data.total})"
      $scope.paginationAfterLoad Albums.perPage, data.total
      return
]

# app.controller "SeasonsController", [ "$scope", "$routeParams", "NavbarFactory", "TvShows", 
# ($scope, $routeParams, NavbarFactory, TvShows) ->  
#   tvShowId = parseInt $routeParams.id

#   $scope.tvShow = null
#   $scope.seasons = []

#   TvShows.get(tvShowId).then (tvShowData) ->
#     $scope.tvShow = tvShowData.data    
#     $scope.Navbar = new NavbarFactory
#     $scope.Navbar.addLink "/tvshows", "TV Shows"
#     $scope.Navbar.addTitle $scope.tvShow.title
#     $scope.tvShow.seasons().then (seasonsData) ->
#       $scope.seasons = seasonsData.data
# ]


# app.controller "EpisodesController", [ "$scope", "$routeParams", "NavbarFactory", "TvShows", "Remote",
# ($scope, $routeParams, NavbarFactory, TvShows, Remote) ->  
#   tvShowId = parseInt $routeParams.tvshowid  
#   seasonId = parseInt $routeParams.id

#   $scope.tvShow = null
#   $scope.season = null
#   $scope.episodes = []

#   TvShows.get(tvShowId).then (tvShowData) ->
#     $scope.tvShow = tvShowData.data
#     $scope.tvShow.seasons().then (seasonsData) ->
#       for season in seasonsData.data
#         if season.seasonid == seasonId || season.season == seasonId
#           $scope.season = season
#           $scope.Navbar = new NavbarFactory
#           $scope.Navbar.addLink "/tvshows", "TV Shows"
#           $scope.Navbar.addLink "/tvshows/#{tvShowId}/seasons", $scope.tvShow.title
#           $scope.Navbar.addTitle "Season #{season.season}"
#           season.episodes().then (episodeData) ->
#             $scope.episodes = episodeData.data

#   $scope.play = (episode) -> Remote.playEpisode(episode.episodeid)
# ]

# app.controller "EpisodeController", [ "$scope", "$routeParams", "Episodes", "NavbarFactory",
# ($scope, $routeParams, Episodes, NavbarFactory) ->
#   episodeId = parseInt $routeParams.id

#   $scope.episode = null  

#   Episodes.get(episodeId).then (episodeData) ->
#     $scope.episode = episodeData.data
#     $scope.Navbar = new NavbarFactory
#     $scope.Navbar.addLink "/tvshows", "TV Shows"
#     $scope.Navbar.addLink "/tvshows/#{$scope.episode.tvshowid}/seasons", $scope.episode.showtitle
#     $scope.Navbar.addLink "/tvshows/#{$scope.episode.tvshowid}/seasons/#{$scope.episode.season}/episodes", "Season #{$scope.episode.season}"
#     $scope.Navbar.addTitle "Episode #{$scope.episode.episode}: #{$scope.episode.title}"
# ]