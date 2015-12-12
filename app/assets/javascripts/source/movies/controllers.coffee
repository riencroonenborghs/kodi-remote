app = angular.module "kodiRemote.movies.controllers", []

app.controller "MoviesController", [ "$scope", "$controller", "Topbar", "Movies", ($scope, $controller, Topbar, Movies) ->
  Topbar.reset()
  Topbar.addTitle "Movies"

  $scope.listService = Movies
  $scope.pushItemsOntoList = (data) ->
    for movie in data.movies
      $scope.list.push movie
    Topbar.addTitle "Movies (#{data.limits.total})"
  $controller "PaginatedController", {$scope: $scope}

  $scope.setItemsOnList = (data) -> $scope.list = data.movies
  $scope.emptyList = -> $scope.list = []
  $controller "SearchController", {$scope: $scope}
]