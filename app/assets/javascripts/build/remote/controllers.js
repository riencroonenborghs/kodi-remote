// Generated by CoffeeScript 1.9.3
(function() {
  var app;

  app = angular.module("kodiRemote.remote.controllers", []);

  app.controller("PlayingNowRemoteController", [
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

  app.controller("RemoteController", [
    "$scope", "RemoteControl", function($scope, RemoteControl) {
      $scope.up = function() {
        return RemoteControl.up();
      };
      $scope.down = function() {
        return RemoteControl.down();
      };
      $scope.left = function() {
        return RemoteControl.left();
      };
      $scope.right = function() {
        return RemoteControl.right();
      };
      $scope.home = function() {
        return RemoteControl.home();
      };
      $scope.enter = function() {
        return RemoteControl.select();
      };
      $scope.back = function() {
        return RemoteControl.back();
      };
      $scope.refresh = function() {
        return RemoteControl.scanLibrary();
      };
      $scope.info = function() {
        return RemoteControl.info();
      };
      return $scope.clean = function() {
        return RemoteControl.clean();
      };
    }
  ]);

}).call(this);
