app = angular.module "kodiRemote.controllers", []

app.controller "AppController", [ "$scope", "Topbar", "$location", ($scope, Topbar, $location) ->
  Topbar.reset()
  Topbar.addTitle "Kodi Remote"
  $scope.Topbar = Topbar

  $scope.visit = (path) -> $location.path path
]