app = angular.module "kodiRemote.movies.controllers", []

app.controller "MoviesController", [ "$scope", "$controller", "Topbar", "Movies", "Remote",
($scope, $controller, Topbar, Movies, Remote) ->
  Topbar.setTitle "Movies"

  $scope.listService = Movies
  $scope.pushItemsOntoList = (data) ->
    for movie in data.movies
      $scope.list.push movie
    Topbar.setTitle "Movies (#{data.limits.total})"
  $controller "PaginatedController", {$scope: $scope}

  $scope.setItemsOnList = (data) -> $scope.list = data.movies
  $scope.emptyList = -> $scope.list = []
  $controller "SearchController", {$scope: $scope}

  $scope.play = (movie) ->
    Remote.playMovie(movie.movieid)
]