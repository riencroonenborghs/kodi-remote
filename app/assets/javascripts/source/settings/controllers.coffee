app = angular.module "kodiRemote.settings.controllers", []

app.controller "SettingsController", [ "$scope", "$location", ($scope, $location) ->  
  $scope.model = 
    server:
      ipAddress: kodiRemote.settings.server
      port: kodiRemote.settings.port

  $scope.save = ->
    chrome.storage.local.clear()
    data = JSON.stringify {server: $scope.model.server.ipAddress, port: $scope.model.server.port}
    chrome.storage.local.set {kodiRemote: data}
    kodiRemote.settings.server  = $scope.model.server.ipAddress
    kodiRemote.settings.port    = $scope.model.server.port

    if $scope.hasServer
      $location.path "/tvshows"
    return
]