var app;

app = angular.module("kodiRemote.controllers", []);

app.controller("AppController", [
  "$scope", "$rootScope", "$interval", "$timeout", "$location", "$mdSidenav", "$mdToast", "SearchService", "Player", "Liked", function($scope, $rootScope, $interval, $timeout, $location, $mdSidenav, $mdToast, SearchService, Player, Liked) {
    var checkServer, initApp, loadFromChromeStorage, loadSettingsInterval;
    $scope.toggleLikedTvShows = function(tvShow) {
      return Liked.toggleTvShow(tvShow);
    };
    $scope.loading = true;
    $scope.$on("topbar.loading", function(event, value) {
      return $scope.loading = value;
    });
    $scope.visit = function(path) {
      $scope.showSearch = false;
      return $location.path(path);
    };
    $scope.visitSeasons = function(tvShowId) {
      return $scope.visit("/tvshows/" + tvShowId + "/seasons");
    };
    $scope.visitEpisodes = function(tvShowId, seasonId) {
      return $scope.visit("/tvshows/" + tvShowId + "/seasons/" + seasonId + "/episodes");
    };
    $scope.visitEpisode = function(episodeId) {
      return $scope.visit("/episodes/" + episodeId);
    };
    $scope.visitMovie = function(movieId) {
      return $scope.visit("/movies/" + movieId);
    };
    $scope.visitGenres = function(type) {
      return $scope.visit(type + "/genres");
    };
    $scope.visitGenre = function(type, genre) {
      return $scope.visit("/genres/" + type + "/" + genre);
    };
    $scope.visitRecentlyAdded = function(type) {
      return $scope.visit("/" + type + "/recently-added");
    };
    $scope.visitYears = function() {
      return $scope.visit("/movies/years");
    };
    $scope.visitYear = function(year) {
      return $scope.visit("/movies/years/" + year);
    };
    $scope.visitRating = function(type) {
      return $scope.visit(type + "/rating");
    };
    $scope.visitAlbums = function() {
      return $scope.visit("/music/albums");
    };
    $scope.visitArtists = function() {
      return $scope.visit("/music/artists");
    };
    $scope.visitAlbum = function(albumId) {
      return $scope.visit("/music/albums/" + albumId);
    };
    initApp = function() {
      var whatsPlaying;
      $scope.toggleSearch = function() {
        $scope.showSearch = !$scope.showSearch;
        $scope.search.query = "";
        $scope.searchService.reset();
        if ($scope.showSearch) {
          return $timeout((function() {
            return $("#search-query").focus();
          }), 500);
        }
      };
      $scope.showSearch = false;
      $scope.search = {
        query: ""
      };
      $scope.searchService = SearchService;
      $scope.performSearch = function() {
        return $scope.searchService.search($scope.search.query);
      };
      $scope.openPlaylist = function() {
        $rootScope.$broadcast("playlist.reload");
        return $mdSidenav("playlist").toggle();
      };
      $scope.$on("show.message", function(event, message) {
        return $mdToast.show({
          controller: "MessageController",
          templateUrl: "app/views/ui/message.html",
          hideDelay: 2000,
          position: "bottom right",
          locals: {
            message: message
          }
        });
      });
      $scope.playingNowVisible = false;
      $scope.playing = null;
      $scope.playerId = null;
      whatsPlaying = function() {
        return Player.activePlayers().then(function(data) {
          data = data.data;
          if (data.length > 0) {
            $scope.playerId = data[0].playerid;
            return Player.playing($scope.playerId).then(function(data) {
              $scope.playing = data.data.item;
              return $scope.playingNowVisible = true;
            });
          } else {
            $scope.playing = null;
            return $scope.playingNowVisible = false;
          }
        });
      };
      whatsPlaying();
      return $interval(whatsPlaying, 1000);
    };
    checkServer = function() {
      $scope.hasServer = false;
      if (!(kodiRemote.settings.server !== null && kodiRemote.settings.port !== null && kodiRemote.settings.requestType)) {
        return;
      }
      return Player.activePlayers().then(function(data) {
        return $scope.hasServer = true;
      });
    };
    checkServer();
    loadFromChromeStorage = function() {
      return chrome.storage.local.get("kodiRemote", function(data) {
        var parsedData;
        console.debug(data);
        if (data.kodiRemote) {
          parsedData = JSON.parse(data.kodiRemote);
          kodiRemote.settings.server = parsedData.server;
          kodiRemote.settings.port = parsedData.port;
          kodiRemote.settings.requestType = parsedData.requestType;
          if (parsedData.liked) {
            kodiRemote.settings.liked.tvShows = parsedData.liked.tvShows;
            kodiRemote.settings.liked.movies = parsedData.liked.movies;
          }
          checkServer();
          return $timeout((function() {
            if ($scope.hasServer) {
              $interval.cancel(loadSettingsInterval);
              initApp();
              return $location.path("/tvshows");
            }
          }), 500);
        }
      });
    };
    loadSettingsInterval = $interval(loadFromChromeStorage, 1000);
    loadFromChromeStorage();
    if ($scope.hasServer) {
      return initApp();
    } else {
      $location.path("/settings");
    }
  }
]);

app.controller("MessageController", [
  "$scope", "message", function($scope, message) {
    return $scope.message = message;
  }
]);
