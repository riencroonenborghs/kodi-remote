app = angular.module "kodiRemote.settings.controllers", []

app.controller "SettingsController", [ "$scope", "$location", ($scope, $location) ->  
  $scope.model = 
    server:
      ipAddress: kodiRemote.settings.server
      port: kodiRemote.settings.port
      requestType: kodiRemote.settings.requestType

  $scope.save = ->
    chrome.storage.local.clear()
    hash =
      server: $scope.model.server.ipAddress
      port: $scope.model.server.port
      requestType: $scope.model.server.requestType
      liked:
        tvShows: kodiRemote.settings.liked.tvShows
        movies: kodiRemote.settings.liked.movies
    data = JSON.stringify hash
    
    chrome.storage.local.set {kodiRemote: data}
    kodiRemote.settings.server      = $scope.model.server.ipAddress
    kodiRemote.settings.port        = $scope.model.server.port
    kodiRemote.settings.requestType = $scope.model.server.requestType

    if $scope.hasServer
      $location.path "/tvshows"
    return
]