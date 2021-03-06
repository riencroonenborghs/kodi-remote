var app;

app = angular.module("kodiRemote.genres.controllers", []);

app.controller("TvShowGenreController", [
  "$scope", "$rootScope", "$routeParams", "Genres", "NavbarFactory", function($scope, $rootScope, $routeParams, Genres, NavbarFactory) {
    var genre;
    genre = $routeParams.genre;
    $scope.genreType = "tvshows";
    $scope.tvShows = [];
    $scope.tvShowGroups = [];
    $scope.showRating = true;
    $scope.showRecentlyAdded = true;
    $scope.showSortDirection = true;
    $scope.beforeSortLoad = function() {
      return $scope.tvShows = [];
    };
    $scope.load = function() {
      var sortDirection;
      sortDirection = $scope.sort ? $scope.sort.direction.methods[$scope.sort.direction.current] : "ascending";
      $rootScope.$broadcast("topbar.loading", true);
      return Genres.get("tvshows", genre, sortDirection).then(function(data) {
        $rootScope.$broadcast("topbar.loading", false);
        $scope.tvShows = data.data;
        $scope.tvShowGroups = kodiRemote.array.inGroupsOf($scope.tvShows, 2);
        $scope.Navbar = new NavbarFactory;
        $scope.Navbar.addLink("/tvshows", "TV Shows");
        $scope.Navbar.addLink("/tvshows/genres", "Genres");
        return $scope.Navbar.addTitle(genre + " (" + data.total + ")");
      });
    };
    return $scope.load();
  }
]);

app.controller("MovieGenreController", [
  "$scope", "$rootScope", "$routeParams", "Genres", "NavbarFactory", function($scope, $rootScope, $routeParams, Genres, NavbarFactory) {
    var genre;
    genre = $routeParams.genre;
    $scope.genreType = "movies";
    $scope.movies = [];
    $scope.movieGroups = [];
    $scope.showRating = true;
    $scope.showYear = true;
    $scope.showRecentlyAdded = true;
    $scope.showSortDirection = true;
    $scope.beforeSortLoad = function() {
      return $scope.tvShows = [];
    };
    $scope.load = function() {
      var sortDirection;
      sortDirection = $scope.sort ? $scope.sort.direction.methods[$scope.sort.direction.current] : "ascending";
      $rootScope.$broadcast("topbar.loading", true);
      return Genres.get("movies", genre, sortDirection).then(function(data) {
        $rootScope.$broadcast("topbar.loading", false);
        $scope.movies = data.data;
        $scope.movieGroups = kodiRemote.array.inGroupsOf($scope.movies, 2);
        $scope.Navbar = new NavbarFactory;
        $scope.Navbar.addLink("/movies", "Movies");
        $scope.Navbar.addLink("/movies/genres", "Genres");
        return $scope.Navbar.addTitle(genre + " (" + data.total + ")");
      });
    };
    return $scope.load();
  }
]);
