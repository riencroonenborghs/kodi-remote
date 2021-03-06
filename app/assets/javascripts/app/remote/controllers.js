var app;

app = angular.module("kodiRemote.remote.controllers", []);

app.controller("PlayingNowRemoteController", [
  "$scope", "$interval", "Player", function($scope, $interval, Player) {
    var getProperties;
    $scope.stop = function() {
      return Player.stop();
    };
    $scope.playPauseState = false;
    $scope.playPause = function() {
      return Player.playPause($scope.playerId).then(function(data) {
        return $scope.playPauseState = !$scope.playPauseState;
      });
    };
    $scope.fastForward = function() {
      return Player.seek($scope.playerId, $scope.percentage + 1);
    };
    $scope.rewind = function() {
      return Player.seek($scope.playerId, $scope.percentage - 1);
    };
    $scope.subtitles = {
      enabled: false,
      available: [],
      valid: ["on", "next", "off"],
      current: 0
    };
    $scope.openMenu = function($mdOpenMenu, ev) {
      return $mdOpenMenu(ev);
    };
    $scope.disableSubtitles = function() {
      return Player.setSubtitle($scope.playerId, "off");
    };
    $scope.enableSubtitles = function() {
      return Player.setSubtitle($scope.playerId, "on");
    };
    $scope.nextSubtitles = function() {
      return Player.setSubtitle($scope.playerId, "next");
    };
    $scope.audioStreams = {
      valid: ["next", "previous"],
      current: 0,
      available: []
    };
    $scope.switchAudioStream = function() {
      var audioStream;
      audioStream = $scope.audioStreams.valid[$scope.audioStreams.current];
      Player.setAudioStream($scope.playerId, audioStream);
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
        return Player.properties($scope.playerId).then(function(data) {
          var hours, minutes, seconds, timeElapsedInSeconds;
          $scope.percentage = data.data.percentage;
          $scope.timeElapsed = data.data.time;
          $scope.subtitles.available = data.data.subtitles;
          $scope.subtitles.enabled = data.data.subtitleenabled;
          $scope.audioStreams.available = data.data.audiostreams;
          timeElapsedInSeconds = data.data.time.hours * 3600 + data.data.time.minutes * 60 + data.data.time.seconds;
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
      return Player.seek($scope.playerId, $scope.percentage);
    };
  }
]);

app.controller("RemoteController", [
  "$scope", "Remote", function($scope, Remote) {
    $scope.up = function() {
      return Remote.up();
    };
    $scope.down = function() {
      return Remote.down();
    };
    $scope.left = function() {
      return Remote.left();
    };
    $scope.right = function() {
      return Remote.right();
    };
    $scope.home = function() {
      return Remote.home();
    };
    $scope.enter = function() {
      return Remote.select();
    };
    $scope.back = function() {
      return Remote.back();
    };
    $scope.refresh = function() {
      return Remote.scanLibrary();
    };
    $scope.info = function() {
      return Remote.info();
    };
    $scope.clean = function() {
      return Remote.clean();
    };
    return $scope.contextMenu = function() {
      return Remote.contextMenu();
    };
  }
]);
