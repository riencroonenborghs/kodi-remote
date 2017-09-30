app = angular.module "kodiRemote.tv.controllers", []

app.controller "TVController", [ "$scope", "TVChannels", "Player", ($scope, TVChannels, Player) ->
  $scope.channels = []
  $scope.loading  = true

  TVChannels.all().then (data) ->
    $scope.loading  = false
    $scope.channels = data.data

  $scope.switchToChannel = (channel) ->
    Player.switchToChannel(channel.channelid)
]