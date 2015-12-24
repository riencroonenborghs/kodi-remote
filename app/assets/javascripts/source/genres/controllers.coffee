app = angular.module "kodiRemote.genres.controllers", []

app.controller "GenreController", [ "$scope", "$rootScope", "$routeParams", "Genres", "NavbarFactory", 
($scope, $rootScope, $routeParams, Genres, NavbarFactory) ->
  genre = $routeParams.genre

  $scope.tvShows = []
  $scope.tvShowGroups = []

  $rootScope.$broadcast "topbar.loading", true
  Genres.get("tvshow", genre).then (data) ->    
    $rootScope.$broadcast "topbar.loading", false
    $scope.tvShows = data.data
    $scope.tvShowGroups = kodiRemote.array.inGroupsOf $scope.tvShows, 2
    $scope.Navbar = new NavbarFactory
    $scope.Navbar.addLink "/tvshows", "TV Shows"
    $scope.Navbar.addLink "/tvshows/genres", "Genres"
    $scope.Navbar.addTitle "#{genre} (#{data.total})"
    
]