var app;

app = angular.module("kodiRemote.movies.controllers", []);

app.controller("MoviesController", [
  "$scope", "$rootScope", "NavbarFactory", "Movies", function($scope, $rootScope, NavbarFactory, Movies) {
    $scope.movies = [];
    $scope.movieGroups = [];
    $scope.showGenre = true;
    $scope.showRating = true;
    $scope.showYear = true;
    $scope.showRecentlyAdded = true;
    $scope.showSortDirection = true;
    $scope.beforeSortLoad = function() {
      $scope.movies = [];
      return $scope.pagination.page = 1;
    };
    return $scope.load = function() {
      $rootScope.$broadcast("topbar.loading", true);
      $scope.loading = true;
      return Movies.all($scope.pagination.page, $scope.sortParams).then(function(data) {
        var i, len, movie, ref;
        $rootScope.$broadcast("topbar.loading", false);
        $scope.loading = false;
        ref = data.data;
        for (i = 0, len = ref.length; i < len; i++) {
          movie = ref[i];
          movie.resume.percentage = movie.resume.position === 0 ? 0 : (movie.resume.position / movie.resume.total) * 100;
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
  "$scope", "$rootScope", "$routeParams", "Movies", "NavbarFactory", "Files", function($scope, $rootScope, $routeParams, Movies, NavbarFactory, Files) {
    var movieId;
    movieId = parseInt($routeParams.id);
    $scope.movie = null;
    $rootScope.$broadcast("topbar.loading", true);
    return Movies.get(movieId).then(function(movieData) {
      $rootScope.$broadcast("topbar.loading", false);
      $scope.movie = movieData.data;
      $scope.Navbar = new NavbarFactory;
      $scope.Navbar.addLink("/movies", "Movies");
      $scope.Navbar.addTitle($scope.movie.title);
      return Files.prepareDownload($scope.movie.file).then(function(fileData) {
        return $scope.filePath = fileData.data.protocol + "://" + kodiRemote.settings.server + ":" + kodiRemote.settings.port + "/" + fileData.data.details.path;
      });
    });
  }
]);

app.controller("RecentlyAddedMoviesController", [
  "$scope", "$rootScope", "NavbarFactory", "Movies", function($scope, $rootScope, NavbarFactory, Movies) {
    $scope.movies = [];
    $scope.movieGroups = [];
    $scope.showGenre = true;
    $scope.showRating = true;
    $scope.showYear = true;
    $rootScope.$broadcast("topbar.loading", true);
    return Movies.recentlyAdded().then(function(data) {
      $rootScope.$broadcast("topbar.loading", false);
      $scope.movies = data.data;
      $scope.movieGroups = kodiRemote.array.inGroupsOf($scope.movies, 2);
      $scope.Navbar = new NavbarFactory;
      $scope.Navbar.addLink("/movies", "Movies");
      $scope.Navbar.addTitle("Recently Added (" + data.total + ")");
    });
  }
]);

app.controller("MovieGenresController", [
  "$scope", "$rootScope", "NavbarFactory", "Genres", function($scope, $rootScope, NavbarFactory, Genres) {
    $scope.showRating = true;
    $scope.showYear = true;
    $scope.showRecentlyAdded = true;
    $scope.genreType = "movies";
    $scope.genres = [];
    $scope.genreGroups = [];
    $rootScope.$broadcast("topbar.loading", true);
    return Genres.all("movie").then(function(data) {
      $rootScope.$broadcast("topbar.loading", false);
      $scope.genres = data.data;
      $scope.genreGroups = kodiRemote.array.inGroupsOf($scope.genres, 2);
      $scope.Navbar = new NavbarFactory;
      $scope.Navbar.addLink("/movies", "Movies");
      return $scope.Navbar.addTitle("Genres (" + data.total + ")");
    });
  }
]);

app.controller("MovieYearsController", [
  "$scope", "$rootScope", "Movies", "NavbarFactory", function($scope, $rootScope, Movies, NavbarFactory) {
    $scope.showGenre = true;
    $scope.showRating = true;
    $scope.showRecentlyAdded = true;
    $scope.years = [];
    $rootScope.$broadcast("topbar.loading", true);
    return Movies.years().then(function(data) {
      var movie, years;
      $rootScope.$broadcast("topbar.loading", false);
      $scope.Navbar = new NavbarFactory;
      $scope.Navbar.addLink("/movies", "Movies");
      $scope.Navbar.addTitle("years");
      years = (function() {
        var i, len, ref, results;
        ref = data.data;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          movie = ref[i];
          results.push(movie.year);
        }
        return results;
      })();
      $scope.years = $.unique(years).sort().reverse();
      return $scope.yearGroups = kodiRemote.array.inGroupsOf($scope.years, 5);
    });
  }
]);

app.controller("MovieYearController", [
  "$scope", "$rootScope", "$routeParams", "Movies", "NavbarFactory", function($scope, $rootScope, $routeParams, Movies, NavbarFactory) {
    var year;
    year = parseInt($routeParams.year);
    $scope.movies = [];
    $scope.movieGroups = [];
    $scope.showGenre = true;
    $scope.showRating = true;
    $scope.showRecentlyAdded = true;
    $scope.showSortDirection = true;
    $scope.beforeSortLoad = function() {
      $scope.movies = [];
      return $scope.pagination.page = 1;
    };
    return $scope.load = function() {
      $rootScope.$broadcast("topbar.loading", true);
      $scope.loading = true;
      return Movies.year(year, $scope.pagination.page, $scope.sortParams).then(function(data) {
        var i, len, movie, ref;
        $rootScope.$broadcast("topbar.loading", false);
        $scope.loading = false;
        ref = data.data;
        for (i = 0, len = ref.length; i < len; i++) {
          movie = ref[i];
          $scope.movies.push(movie);
        }
        $scope.movieGroups = kodiRemote.array.inGroupsOf($scope.movies, 2);
        $scope.paginationAfterLoad(Movies.perPage, data.total);
        $scope.Navbar = new NavbarFactory;
        $scope.Navbar.addLink("/movies", "Movies");
        $scope.Navbar.addLink("/movies/years", "By Year");
        return $scope.Navbar.addTitle(year + " (" + data.total + ")");
      });
    };
  }
]);

app.controller("MoviesRatingController", [
  "$scope", "$rootScope", "NavbarFactory", "Movies", function($scope, $rootScope, NavbarFactory, Movies) {
    $scope.movies = [];
    $scope.movieGroups = [];
    $scope.showRating = true;
    $scope.showYear = true;
    $scope.showRecentlyAdded = true;
    $scope.showSortDirection = true;
    $scope.beforeSortLoad = function() {
      $scope.movies = [];
      return $scope.pagination.page = 1;
    };
    return $scope.load = function() {
      $rootScope.$broadcast("topbar.loading", true);
      $scope.sortParams = {
        by: "rating",
        direction: "ascending"
      };
      if ($scope.sort) {
        $scope.sortParams.direction = $scope.sort.direction.methods[$scope.sort.direction.current];
      }
      $scope.loading = true;
      return Movies.all($scope.pagination.page, $scope.sortParams).then(function(data) {
        var i, len, movie, ref;
        $rootScope.$broadcast("topbar.loading", false);
        $scope.loading = false;
        ref = data.data;
        for (i = 0, len = ref.length; i < len; i++) {
          movie = ref[i];
          $scope.movies.push(movie);
        }
        $scope.movieGroups = kodiRemote.array.inGroupsOf($scope.movies, 2);
        $scope.Navbar = new NavbarFactory;
        $scope.Navbar.addLink("/movies", "Movies (" + data.total + ")");
        $scope.Navbar.addTitle("Rating");
        $scope.paginationAfterLoad(Movies.perPage, data.total);
      });
    };
  }
]);
