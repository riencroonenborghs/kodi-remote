app = angular.module "kodiRemote.settings.controllers", []

app.controller "SettingsController", [ "$scope", "Topbar", ($scope, Topbar) ->  
  Topbar.setTitle "Settings"

  $scope.model = 
    server:
      ipAddress: kodiRemote.settings.server
      port: kodiRemote.settings.port
]