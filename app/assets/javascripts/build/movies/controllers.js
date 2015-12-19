// Generated by CoffeeScript 1.9.3
(function() {
  var app;

  app = angular.module("kodiRemote.movies.controllers", []);

  app.controller("MoviesController", [
    "$scope", "NavbarFactory", "Movies", "Remote", function($scope, NavbarFactory, Movies, Remote) {
      $scope.movies = [];
      $scope.movieGroups = [];
      $scope.beforeSortLoad = function() {
        $scope.movies = [];
        return $scope.pagination.page = 1;
      };
      return $scope.load = function() {
        $scope.loading = true;
        return Movies.all($scope.pagination.page, $scope.sortParams).then(function(data) {
          var i, len, movie, ref;
          $scope.loading = false;
          ref = data.data;
          for (i = 0, len = ref.length; i < len; i++) {
            movie = ref[i];
            $scope.movies.push(movie);
          }
          $scope.movieGroups = kodiRemote.array.inGroupsOf($scope.movies, 2);
          $scope.Navbar = new NavbarFactory;
          $scope.Navbar.addTitle("Movies (" + data.total + ")");
          $scope.paginationAfterLoad(Movies.perPage, data.total);
        });
      };
    }
  ]);

  app.controller("MovieController", [
    "$scope", "$routeParams", "Movies", "NavbarFactory", function($scope, $routeParams, Movies, NavbarFactory) {
      var movieId;
      movieId = parseInt($routeParams.id);
      $scope.movie = null;
      return Movies.get(movieId).then(function(movieData) {
        $scope.movie = movieData.data;
        $scope.Navbar = new NavbarFactory;
        $scope.Navbar.addLink("/movies", "Movies");
        return $scope.Navbar.addTitle($scope.movie.title);
      });
    }
  ]);

}).call(this);
