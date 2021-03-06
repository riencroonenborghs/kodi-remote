var app;

app = angular.module("kodiRemote.playlist.controllers", []);

app.controller("PlaylistController", [
  "$scope", "$mdSidenav", "$timeout", "Playlist", function($scope, $mdSidenav, $timeout, Playlist) {
    var loadItems;
    $scope.items = [];
    loadItems = function() {
      return Playlist.items().then(function(data) {
        return $scope.items = data.data;
      });
    };
    loadItems();
    $scope.$on("playlist.reload", function() {
      return loadItems();
    });
    $scope.visitItem = function(item) {
      if (item.type === "episode") {
        $scope.visitEpisode(item.id);
      }
      if (item.type === "movie") {
        $scope.visitMovie(item.id);
      }
      return $scope.close();
    };
    $scope.removeItem = function(index) {
      Playlist.remove(index);
      return $timeout((function() {
        return loadItems();
      }), 500);
    };
    return $scope.clear = function() {
      Playlist.clear();
      return $timeout((function() {
        return loadItems();
      }), 500);
    };
  }
]);
