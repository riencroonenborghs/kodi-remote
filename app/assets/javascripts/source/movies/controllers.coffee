app = angular.module "kodiRemote.movies.controllers", []

app.controller "MoviesController", [ "$scope", "Topbar", "Remote", ($scope, Topbar, Remote) ->
  Topbar.reset()
  Topbar.addTitle "Movies"

  $scope.loading = true
  $scope.movies = []
  Remote.videoLibrary.movies.get().then (data) -> 
    $scope.loading = false
    $scope.movies = data.movies
    Topbar.addTitle "Movies (#{data.limits.total})"
    return
]