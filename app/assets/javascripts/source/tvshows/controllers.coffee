app = angular.module "kodiRemote.tvshows.controllers", []

app.controller "TvShowsController", [ "$scope", "$rootScope", "NavbarFactory", "TvShows", ($scope, $rootScope, NavbarFactory, TvShows) ->  
  $scope.tvShows = []  
  $scope.tvShowGroups = []

  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad before load
  $scope.showGenre = true
  $scope.showRating = true
  $scope.showRecentlyAdded = true
  $scope.showSortDirection = true
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

app.controller "TvShowGenresController", [ "$scope", "$rootScope", "NavbarFactory", "Genres", ($scope, $rootScope,NavbarFactory, Genres) ->    
  $scope.showRating = true
  $scope.showRecentlyAdded = true
  
  $scope.genreType = "tvshows"
  $scope.genres = []
  $scope.genreGroups = []

  $rootScope.$broadcast "topbar.loading", true
  Genres.all("tvshow").then (data) ->    
    $rootScope.$broadcast "topbar.loading", false
    $scope.genres = data.data
    $scope.genreGroups = kodiRemote.array.inGroupsOf $scope.genres, 2
    $scope.Navbar = new NavbarFactory
    $scope.Navbar.addLink "/tvshows", "TV Shows"
    $scope.Navbar.addTitle "Genres (#{data.total})"  
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

app.controller "EpisodeController", [ "$scope", "$rootScope", "$routeParams", "Episodes", "NavbarFactory", "Files",
($scope, $rootScope, $routeParams, Episodes, NavbarFactory, Files) ->
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

    Files.prepareDownload($scope.episode.file).then (fileData) ->   
      $scope.filePath = "#{fileData.data.protocol}://#{kodiRemote.settings.server}:#{kodiRemote.settings.port}/#{fileData.data.details.path}"
]

app.controller "RecentlyAddedEpisodesController", [ "$scope", "$rootScope", "$routeParams", "NavbarFactory", "Episodes",
($scope, $rootScope, $routeParams, NavbarFactory, Episodes) ->  
  $scope.episodes = []
  $scope.episodeGroups = []

  $scope.showGenre = true
  $scope.showRating = true

  $rootScope.$broadcast "topbar.loading", true
  Episodes.recentlyAdded().then (data) ->
    $rootScope.$broadcast "topbar.loading", false
    $scope.episodes = data.data
    $scope.episodeGroups = kodiRemote.array.inGroupsOf $scope.episodes, 2
    $scope.Navbar = new NavbarFactory
    $scope.Navbar.addLink "/tvshows", "TV Shows"
    $scope.Navbar.addTitle "Episodes"
    $scope.Navbar.addTitle "Recently Added (#{data.total})"
]

app.controller "TvShowsRatingController", [ "$scope", "$rootScope", "NavbarFactory", "TvShows", ($scope, $rootScope, NavbarFactory, TvShows) ->  
  $scope.tvShows = []  
  $scope.tvShowGroups = []

  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad before load
  $scope.showGenre = true
  $scope.showRecentlyAdded = true
  $scope.showSortDirection = true
  $scope.beforeSortLoad = ->
    $scope.tvShows = []
    $scope.pagination.page = 1

  # autoScrollPaginate directive
  # - sets $scope.pagination hash
  # - uses $scope.paginationAfterLoad to calculate $scope.pagination.more

  $scope.load = ->
    $rootScope.$broadcast "topbar.loading", true

    $scope.sortParams =
      by: "rating"
      direction: "ascending"
    $scope.sortParams.direction = $scope.sort.direction.methods[$scope.sort.direction.current] if $scope.sort

    TvShows.all($scope.pagination.page, $scope.sortParams).then (data) ->
      $rootScope.$broadcast "topbar.loading", false
      for tvShow in data.data
        $scope.tvShows.push tvShow

      $scope.tvShowGroups = kodiRemote.array.inGroupsOf $scope.tvShows, 2      

      $scope.Navbar = new NavbarFactory
      $scope.Navbar.addLink "/tvshows", "TV Shows (#{data.total})"
      $scope.Navbar.addTitle "Rating"
      $scope.paginationAfterLoad TvShows.perPage, data.total
      return
]