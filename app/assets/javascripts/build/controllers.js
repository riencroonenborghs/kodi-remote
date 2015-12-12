// Generated by CoffeeScript 1.9.3
(function() {
  var app;

  app = angular.module("kodiRemote.controllers", []);

  app.controller("AppController", [
    "$scope", "Topbar", "$location", function($scope, Topbar, $location) {
      Topbar.reset();
      Topbar.addTitle("Kodi Remote");
      $scope.Topbar = Topbar;
      return $scope.visit = function(path) {
        return $location.path(path);
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
