app = angular.module "kodiRemote.genres.controllers", []

app.controller "TvShowGenreController", [ "$scope", "$rootScope", "$routeParams", "Genres", "NavbarFactory", 
($scope, $rootScope, $routeParams, Genres, NavbarFactory) ->
  genre = $routeParams.genre

  $scope.genreType = "tvshows"

  $scope.tvShows = []
  $scope.tvShowGroups = []

  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad before load
  $scope.showRating = true
  $scope.showRecentlyAdded = true
  $scope.showSortDirection = true
  $scope.beforeSortLoad = ->
    $scope.tvShows = []

  $scope.load = ->
    sortDirection = if $scope.sort then $scope.sort.direction.methods[$scope.sort.direction.current] else "ascending"
    $rootScope.$broadcast "topbar.loading", true
    Genres.get("tvshows", genre, sortDirection).then (data) ->    
      $rootScope.$broadcast "topbar.loading", false
      $scope.tvShows = data.data
      $scope.tvShowGroups = kodiRemote.array.inGroupsOf $scope.tvShows, 2
      $scope.Navbar = new NavbarFactory
      $scope.Navbar.addLink "/tvshows", "TV Shows"
      $scope.Navbar.addLink "/tvshows/genres", "Genres"
      $scope.Navbar.addTitle "#{genre} (#{data.total})"    
  $scope.load()
]

app.controller "MovieGenreController", [ "$scope", "$rootScope", "$routeParams", "Genres", "NavbarFactory", 
($scope, $rootScope, $routeParams, Genres, NavbarFactory) ->
  genre = $routeParams.genre

  $scope.genreType = "movies"

  $scope.movies = []
  $scope.movieGroups = []

  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad before load
  $scope.showRating = true
  $scope.showYear = true
  $scope.showRecentlyAdded = true
  $scope.showSortDirection = true
  $scope.beforeSortLoad = ->
    $scope.tvShows = []

  $scope.load = ->
    sortDirection = if $scope.sort then $scope.sort.direction.methods[$scope.sort.direction.current] else "ascending"
    $rootScope.$broadcast "topbar.loading", true
    Genres.get("movies", genre, sortDirection).then (data) ->
      $rootScope.$broadcast "topbar.loading", false
      $scope.movies = data.data
      $scope.movieGroups = kodiRemote.array.inGroupsOf $scope.movies, 2
      $scope.Navbar = new NavbarFactory
      $scope.Navbar.addLink "/movies", "Movies"
      $scope.Navbar.addLink "/movies/genres", "Genres"
      $scope.Navbar.addTitle "#{genre} (#{data.total})"    
  $scope.load()
]