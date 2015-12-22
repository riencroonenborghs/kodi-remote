// Generated by CoffeeScript 1.9.3
(function() {
  var app;

  app = angular.module("kodiRemote.controllers", []);

  app.controller("AppController", [
    "$scope", "$rootScope", "$interval", "$timeout", "$location", "$mdSidenav", "SearchService", "Player", function($scope, $rootScope, $interval, $timeout, $location, $mdSidenav, SearchService, Player) {
      var checkServer, initApp, loadSettings, loadSettingsInterval;
      $scope.loading = true;
      $scope.$on("topbar.loading", function(event, value) {
        console.debug("topbar.loading " + value);
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
        if (!(kodiRemote.settings.server !== null && kodiRemote.settings.port !== null)) {
          return;
        }
        return Player.activePlayers().then(function(data) {
          return $scope.hasServer = true;
        });
      };
      checkServer();
      loadSettings = function() {
        return chrome.storage.local.get("kodiRemote", function(data) {
          var parsedData;
          if (data.kodiRemote) {
            parsedData = JSON.parse(data.kodiRemote);
            kodiRemote.settings.server = parsedData.server;
            kodiRemote.settings.port = parsedData.port;
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
      loadSettingsInterval = $interval(loadSettings, 1000);
      loadSettings();
      if ($scope.hasServer) {
        return initApp();
      } else {
        $location.path("/settings");
      }
    }
  ]);

}).call(this);
