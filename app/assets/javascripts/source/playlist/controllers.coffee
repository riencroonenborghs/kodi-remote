app = angular.module "kodiRemote.playlist.controllers", []

app.controller "PlaylistController", [ "$scope", "$mdSidenav", ($scope, $mdSidenav) ->
  $scope.close = -> $mdSidenav("playlist").close()
]