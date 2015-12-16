app = angular.module "kodiRemote.remote.controllers", []

app.controller "RemoteController", [ "$scope", "Topbar", "RemoteControl", ($scope, Topbar, RemoteControl) ->
  Topbar.setTitle "Remote Controller"
  
  $scope.up = -> RemoteControl.up()
  $scope.down = -> RemoteControl.down()
  $scope.left = -> RemoteControl.left()
  $scope.right = -> RemoteControl.right()
  $scope.home = -> RemoteControl.home()
  $scope.enter = -> RemoteControl.select()
  $scope.back = -> RemoteControl.back()
  $scope.refresh = -> RemoteControl.scanLibrary()
  $scope.info = -> RemoteControl.info()
]