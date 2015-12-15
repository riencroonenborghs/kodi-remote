// Generated by CoffeeScript 1.9.3
(function() {
  var app;

  app = angular.module("kodiRemote.controllers", []);

  app.controller("AppController", [
    "$scope", "$interval", "$timeout", "$location", "SearchService", "Topbar", "Remote", function($scope, $interval, $timeout, $location, SearchService, Topbar, Remote) {
      var initApp, loadSettings, loadSettingsInterval;
      initApp = function() {
        var whatsPlaying;
        $scope.Topbar = Topbar;
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
        $scope.visit = function(path) {
          $scope.showSearch = false;
          return $location.path(path);
        };
        $scope.visitSeasons = function(tvShowId) {
          return $scope.visit("/tvshows/" + tvShowId + "/seasons");
        };
        $scope.remoteVisible = false;
        $scope.playing = null;
        $scope.playerId = null;
        whatsPlaying = function() {
          return Remote.Player.activePlayers().then(function(data) {
            if (data.length > 0) {
              $scope.playerId = data[0].playerid;
              return Remote.Player.playing($scope.playerId).then(function(data) {
                $scope.playing = data.item;
                return $scope.remoteVisible = true;
              });
            } else {
              $scope.playing = null;
              return $scope.remoteVisible = false;
            }
          });
        };
        whatsPlaying();
        $interval(whatsPlaying, 1000);
        return $scope.keyPressed = function(event) {
          return console.debug(event);
        };
      };
      $scope.hasServer = kodiRemote.settings.server !== null && kodiRemote.settings.port !== null;
      loadSettings = function() {
        chrome.storage.local.get("kodiRemote", function(data) {
          var parsedData;
          if (data.kodiRemote) {
            parsedData = JSON.parse(data.kodiRemote);
            kodiRemote.settings.server = parsedData.server;
            kodiRemote.settings.port = parsedData.port;
            $scope.hasServer = kodiRemote.settings.server !== null && kodiRemote.settings.port !== null;
            initApp();
            return $location.path("/tvshows");
          }
        });
        if ($scope.hasServer) {
          $interval.cancel(loadSettingsInterval);
        }
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

  app.controller("PlayingRemoteController", [
    "$scope", "$interval", "Remote", function($scope, $interval, Remote) {
      var getProperties;
      $scope.stop = function() {
        return Remote.Player.stop();
      };
      $scope.playPauseState = false;
      $scope.playPause = function() {
        return Remote.Player.playPause($scope.playerId).then(function(data) {
          return $scope.playPauseState = !$scope.playPauseState;
        });
      };
      $scope.fastForward = function() {
        return Remote.Player.seek($scope.playerId, $scope.percentage + 1);
      };
      $scope.rewind = function() {
        return Remote.Player.seek($scope.playerId, $scope.percentage - 1);
      };
      $scope.subtitles = {
        enabled: false,
        available: [],
        valid: ["on", "next", "off"],
        current: 0
      };
      $scope.switchSubtitle = function() {
        var subtitle;
        subtitle = $scope.subtitles.valid[$scope.subtitles.current];
        Remote.Player.setSubtitle($scope.playerId, subtitle);
        $scope.subtitles.current += 1;
        if ($scope.subtitles.current === $scope.subtitles.valid.length) {
          return $scope.subtitles.current = 0;
        }
      };
      $scope.audioStreams = {
        valid: ["next", "previous"],
        current: 0,
        available: []
      };
      $scope.switchAudioStream = function() {
        var audioStream;
        audioStream = $scope.audioStreams.valid[$scope.audioStreams.current];
        Remote.Player.setAudioStream($scope.playerId, audioStream);
        $scope.audioStreams.current += 1;
        if ($scope.audioStreams.current === $scope.audioStreams.valid.length) {
          return $scope.audioStreams.current = 0;
        }
      };
      $scope.percentage = 0;
      $scope.timeElapsed = 0;
      $scope.timeRemaining = 0;
      getProperties = function() {
        if ($scope.playing) {
          return Remote.Player.properties($scope.playerId).then(function(data) {
            var hours, minutes, seconds, timeElapsedInSeconds;
            $scope.percentage = data.percentage;
            $scope.timeElapsed = data.time;
            $scope.subtitles.available = data.subtitles;
            $scope.subtitles.enabled = data.subtitleenabled;
            $scope.audioStreams.available = data.audiostreams;
            timeElapsedInSeconds = data.time.hours * 3600 + data.time.minutes * 60 + data.time.seconds;
            seconds = $scope.playing.runtime - timeElapsedInSeconds;
            hours = Math.floor(seconds / 3600);
            minutes = Math.floor((seconds - (hours * 3600)) / 60);
            seconds = Math.floor((seconds - (hours * 3600)) % 60);
            return $scope.timeRemaining = {
              hours: hours,
              minutes: minutes,
              seconds: seconds
            };
          });
        }
      };
      $interval(getProperties, 1000);
      return $scope.jumpTo = function() {
        return Remote.Player.seek($scope.playerId, $scope.percentage);
      };
    }
  ]);

  app.controller("PaginatedController", [
    "$scope", function($scope) {
      $scope.loading = false;
      $scope.list = [];
      $scope.page = 1;
      $scope.morePages = true;
      $scope.nextPage = function() {
        $scope.page += 1;
        return $scope.loadCurrentPage();
      };
      $scope.loadCurrentPage = function() {
        $scope.loading = true;
        return $scope.listService.index($scope.page).then(function(data) {
          var totalItemsInList;
          $scope.pushItemsOntoList(data);
          $scope.loading = false;
          totalItemsInList = data.limits.total;
          $scope.morePages = ($scope.page * $scope.listService.perPage) < totalItemsInList;
        });
      };
      return $scope.loadCurrentPage();
    }
  ]);

  app.controller("SearchController", [
    "$scope", function($scope) {
      $scope.search = {
        query: ""
      };
      return $scope.performSearch = function() {
        if ($scope.search.query.length > 2) {
          $scope.loading = true;
          return $scope.listService.search($scope.search.query).then(function(data) {
            $scope.setItemsOnList(data);
            $scope.morePages = false;
            $scope.loading = false;
          });
        } else {
          $scope.emptyList();
          $scope.page = 1;
          $scope.morePages = true;
          return $scope.loadCurrentPage();
        }
      };
    }
  ]);

}).call(this);
