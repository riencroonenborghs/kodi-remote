app = angular.module "kodiRemote.genres.controllers", []

app.controller "TvShowGenreController", [ "$scope", "$rootScope", "$routeParams", "Genres", "NavbarFactory", 
($scope, $rootScope, $routeParams, Genres, NavbarFactory) ->
  genre = $routeParams.genre

  $scope.tvShows = []
  $scope.tvShowGroups = []

  $rootScope.$broadcast "topbar.loading", true
  Genres.get("tvshows", genre).then (data) ->    
    $rootScope.$broadcast "topbar.loading", false
    $scope.tvShows = data.data
    $scope.tvShowGroups = kodiRemote.array.inGroupsOf $scope.tvShows, 2
    $scope.Navbar = new NavbarFactory
    $scope.Navbar.addLink "/tvshows", "TV Shows"
    $scope.Navbar.addLink "/tvshows/genres", "Genres"
    $scope.Navbar.addTitle "#{genre} (#{data.total})"    
]

app.controller "MovieGenreController", [ "$scope", "$rootScope", "$routeParams", "Genres", "NavbarFactory", 
($scope, $rootScope, $routeParams, Genres, NavbarFactory) ->
  genre = $routeParams.genre

  $scope.movies = []
  $scope.movieGroups = []

  $rootScope.$broadcast "topbar.loading", true
  Genres.get("movies", genre).then (data) ->
    console.debug data
    $rootScope.$broadcast "topbar.loading", false
    $scope.movies = data.data
    $scope.movieGroups = kodiRemote.array.inGroupsOf $scope.movies, 2
    $scope.Navbar = new NavbarFactory
    $scope.Navbar.addLink "/movies", "Movies"
    $scope.Navbar.addLink "/movies/genres", "Genres"
    $scope.Navbar.addTitle "#{genre} (#{data.total})"    
]