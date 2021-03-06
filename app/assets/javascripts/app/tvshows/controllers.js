var app,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

app = angular.module("kodiRemote.tvshows.controllers", []);

app.controller("TvShowsController", [
  "$scope", "$rootScope", "NavbarFactory", "TvShows", function($scope, $rootScope, NavbarFactory, TvShows) {
    $scope.tvShows = [];
    $scope.tvShowGroups = [];
    $scope.showGenre = true;
    $scope.showRating = true;
    $scope.showRecentlyAdded = true;
    $scope.showSortDirection = true;
    $scope.beforeSortLoad = function() {
      $scope.tvShows = [];
      return $scope.pagination.page = 1;
    };
    return $scope.load = function() {
      $rootScope.$broadcast("topbar.loading", true);
      return TvShows.all($scope.pagination.page, $scope.sortParams).then(function(data) {
        var i, len, ref, ref1, tvShow;
        $rootScope.$broadcast("topbar.loading", false);
        ref = data.data;
        for (i = 0, len = ref.length; i < len; i++) {
          tvShow = ref[i];
          tvShow.liked = false;
          if (ref1 = tvShow.tvshowid, indexOf.call(kodiRemote.settings.liked.tvShows, ref1) >= 0) {
            tvShow.liked = true;
          }
          $scope.tvShows.push(tvShow);
        }
        $scope.tvShowGroups = kodiRemote.array.inGroupsOf($scope.tvShows, 2);
        $scope.Navbar = new NavbarFactory;
        $scope.Navbar.addTitle("TV Shows (" + data.total + ")");
        $scope.paginationAfterLoad(TvShows.perPage, data.total);
      });
    };
  }
]);

app.controller("TvShowGenresController", [
  "$scope", "$rootScope", "NavbarFactory", "Genres", function($scope, $rootScope, NavbarFactory, Genres) {
    $scope.showRating = true;
    $scope.showRecentlyAdded = true;
    $scope.genreType = "tvshows";
    $scope.genres = [];
    $scope.genreGroups = [];
    $rootScope.$broadcast("topbar.loading", true);
    return Genres.all("tvshow").then(function(data) {
      $rootScope.$broadcast("topbar.loading", false);
      $scope.genres = data.data;
      $scope.genreGroups = kodiRemote.array.inGroupsOf($scope.genres, 2);
      $scope.Navbar = new NavbarFactory;
      $scope.Navbar.addLink("/tvshows", "TV Shows");
      return $scope.Navbar.addTitle("Genres (" + data.total + ")");
    });
  }
]);

app.controller("SeasonsController", [
  "$scope", "$rootScope", "$routeParams", "NavbarFactory", "TvShows", function($scope, $rootScope, $routeParams, NavbarFactory, TvShows) {
    var tvShowId;
    tvShowId = parseInt($routeParams.id);
    $scope.tvShow = null;
    $scope.seasons = [];
    $scope.seasonGroups = [];
    $rootScope.$broadcast("topbar.loading", true);
    return TvShows.get(tvShowId).then(function(tvShowData) {
      $rootScope.$broadcast("topbar.loading", false);
      $scope.tvShow = tvShowData.data;
      $scope.Navbar = new NavbarFactory;
      $scope.Navbar.addLink("/tvshows", "TV Shows");
      $scope.Navbar.addTitle($scope.tvShow.title);
      return $scope.tvShow.seasons().then(function(seasonsData) {
        $scope.seasons = seasonsData.data;
        return $scope.seasonGroups = kodiRemote.array.inGroupsOf($scope.seasons, 2);
      });
    });
  }
]);

app.controller("EpisodesController", [
  "$scope", "$rootScope", "$routeParams", "NavbarFactory", "TvShows", function($scope, $rootScope, $routeParams, NavbarFactory, TvShows) {
    var seasonId, tvShowId;
    tvShowId = parseInt($routeParams.tvshowid);
    seasonId = parseInt($routeParams.id);
    $scope.tvShow = null;
    $scope.season = null;
    $scope.episodes = [];
    $scope.episodeGroups = [];
    $rootScope.$broadcast("topbar.loading", true);
    return TvShows.get(tvShowId).then(function(tvShowData) {
      $scope.tvShow = tvShowData.data;
      return $scope.tvShow.seasons().then(function(seasonsData) {
        var i, len, ref, results, season;
        ref = seasonsData.data;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          season = ref[i];
          if (season.seasonid === seasonId || season.season === seasonId) {
            $scope.season = season;
            $scope.Navbar = new NavbarFactory;
            $scope.Navbar.addLink("/tvshows", "TV Shows");
            $scope.Navbar.addLink("/tvshows/" + tvShowId + "/seasons", $scope.tvShow.title);
            $scope.Navbar.addTitle("Season " + season.season);
            results.push(season.episodes().then(function(episodeData) {
              $rootScope.$broadcast("topbar.loading", false);
              $scope.episodes = episodeData.data;
              return $scope.episodeGroups = kodiRemote.array.inGroupsOf($scope.episodes, 2);
            }));
          } else {
            results.push(void 0);
          }
        }
        return results;
      });
    });
  }
]);

app.controller("EpisodeController", [
  "$scope", "$rootScope", "$routeParams", "Episodes", "NavbarFactory", "Files", function($scope, $rootScope, $routeParams, Episodes, NavbarFactory, Files) {
    var episodeId;
    episodeId = parseInt($routeParams.id);
    $scope.episode = null;
    $rootScope.$broadcast("topbar.loading", true);
    return Episodes.get(episodeId).then(function(episodeData) {
      $rootScope.$broadcast("topbar.loading", false);
      $scope.episode = episodeData.data;
      $scope.Navbar = new NavbarFactory;
      $scope.Navbar.addLink("/tvshows", "TV Shows");
      $scope.Navbar.addLink("/tvshows/" + $scope.episode.tvshowid + "/seasons", $scope.episode.showtitle);
      $scope.Navbar.addLink("/tvshows/" + $scope.episode.tvshowid + "/seasons/" + $scope.episode.season + "/episodes", "Season " + $scope.episode.season);
      $scope.Navbar.addTitle("Episode " + $scope.episode.episode + ": " + $scope.episode.title);
      return Files.prepareDownload($scope.episode.file).then(function(fileData) {
        return $scope.filePath = fileData.data.protocol + "://" + kodiRemote.settings.server + ":" + kodiRemote.settings.port + "/" + fileData.data.details.path;
      });
    });
  }
]);

app.controller("RecentlyAddedEpisodesController", [
  "$scope", "$rootScope", "$routeParams", "NavbarFactory", "Episodes", function($scope, $rootScope, $routeParams, NavbarFactory, Episodes) {
    $scope.episodes = [];
    $scope.episodeGroups = [];
    $scope.showGenre = true;
    $scope.showRating = true;
    $rootScope.$broadcast("topbar.loading", true);
    return Episodes.recentlyAdded().then(function(data) {
      $rootScope.$broadcast("topbar.loading", false);
      $scope.episodes = data.data;
      $scope.episodeGroups = kodiRemote.array.inGroupsOf($scope.episodes, 2);
      $scope.Navbar = new NavbarFactory;
      $scope.Navbar.addLink("/tvshows", "TV Shows");
      $scope.Navbar.addTitle("Episodes");
      return $scope.Navbar.addTitle("Recently Added (" + data.total + ")");
    });
  }
]);

app.controller("TvShowsRatingController", [
  "$scope", "$rootScope", "NavbarFactory", "TvShows", function($scope, $rootScope, NavbarFactory, TvShows) {
    $scope.tvShows = [];
    $scope.tvShowGroups = [];
    $scope.showGenre = true;
    $scope.showRecentlyAdded = true;
    $scope.showSortDirection = true;
    $scope.beforeSortLoad = function() {
      $scope.tvShows = [];
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
      return TvShows.all($scope.pagination.page, $scope.sortParams).then(function(data) {
        var i, len, ref, tvShow;
        $rootScope.$broadcast("topbar.loading", false);
        ref = data.data;
        for (i = 0, len = ref.length; i < len; i++) {
          tvShow = ref[i];
          $scope.tvShows.push(tvShow);
        }
        $scope.tvShowGroups = kodiRemote.array.inGroupsOf($scope.tvShows, 2);
        $scope.Navbar = new NavbarFactory;
        $scope.Navbar.addLink("/tvshows", "TV Shows (" + data.total + ")");
        $scope.Navbar.addTitle("Rating");
        $scope.paginationAfterLoad(TvShows.perPage, data.total);
      });
    };
  }
]);
