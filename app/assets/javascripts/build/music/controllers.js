// Generated by CoffeeScript 1.9.3
(function() {
  var app;

  app = angular.module("kodiRemote.music.controllers", []);

  app.controller("AlbumsController", [
    "$scope", "NavbarFactory", "Albums", function($scope, NavbarFactory, Albums) {
      $scope.albums = [];
      $scope.beforeSortLoad = function() {
        $scope.albums = [];
        return $scope.pagination.page = 1;
      };
      return $scope.load = function() {
        $scope.loading = true;
        return Albums.all($scope.pagination.page, $scope.sortParams).then(function(data) {
          var album, i, len, ref;
          $scope.loading = false;
          ref = data.data;
          for (i = 0, len = ref.length; i < len; i++) {
            album = ref[i];
            $scope.albums.push(album);
          }
          $scope.Navbar = new NavbarFactory;
          $scope.Navbar.addTitle("Albums (" + data.total + ")");
          $scope.paginationAfterLoad(Albums.perPage, data.total);
        });
      };
    }
  ]);

}).call(this);
