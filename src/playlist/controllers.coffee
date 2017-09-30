app = angular.module "kodiRemote.playlist.controllers", []

app.controller "PlaylistController", [ "$scope", "$mdSidenav", "$timeout", "Playlist", 
($scope, $mdSidenav, $timeout, Playlist) ->
  # $scope.close = -> $mdSidenav("playlist").close()

  $scope.items = []

  loadItems = ->
    Playlist.items().then (data) ->
      $scope.items = data.data
  loadItems()

  $scope.$on "playlist.reload", ->
    loadItems()

  $scope.visitItem = (item) ->
    if item.type == "episode"
      $scope.visitEpisode item.id
    if item.type == "movie"
      $scope.visitMovie item.id
    $scope.close()

  $scope.removeItem = (index) ->
    Playlist.remove(index)
    $timeout (-> loadItems()), 500

  $scope.clear = -> 
    Playlist.clear()
    $timeout (-> loadItems()), 500
]