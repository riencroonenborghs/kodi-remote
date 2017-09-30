var app;

app = angular.module("kodiRemote.tv.controllers", []);

app.controller("TVController", [
  "$scope", "TVChannels", "Player", function($scope, TVChannels, Player) {
    $scope.channels = [];
    $scope.loading = true;
    TVChannels.all().then(function(data) {
      $scope.loading = false;
      return $scope.channels = data.data;
    });
    return $scope.switchToChannel = function(channel) {
      return Player.switchToChannel(channel.channelid);
    };
  }
]);
