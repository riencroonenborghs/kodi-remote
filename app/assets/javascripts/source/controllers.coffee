app = angular.module "kodiRemote.controllers", []

app.controller "AppController", [ "$scope", "$interval", "Topbar", "$location", "Remote", 
($scope, $interval, Topbar, $location, Remote) ->
  Topbar.setTitle "Kodi Remote"
  $scope.Topbar = Topbar

  $scope.visit = (path) -> $location.path path

  $scope.playing = null
  $scope.playerId = null
  $scope.playPauseState = false

  whatsPlaying = ->    
    Remote.Player.activePlayers().then (data) ->      
      if data.length > 0
        $scope.playerId = data[0].playerid
        Remote.Player.playing($scope.playerId).then (data) ->
          $scope.playing = data.item
      else
        $scope.playing = null
  whatsPlaying()
  $interval whatsPlaying, 5000

  $scope.stop = -> Remote.Player.stop()
  $scope.playPause = -> 
    Remote.Player.playPause($scope.playerId).then (data) ->
      $scope.playPauseState = !$scope.playPauseState
]

app.controller "PaginatedController", [ "$scope", ($scope) ->
  # $scope.listService        = service that loads the paginated list
  # $scope.pushItemsOntoList  = method that handles adding the items onto the list

  $scope.loading          = false
  $scope.list             = []
  $scope.page             = 1
  $scope.morePages        = true  

  $scope.nextPage = ->
    $scope.page += 1
    $scope.loadCurrentPage()

  $scope.loadCurrentPage = ->
    $scope.loading = true
    $scope.listService.index($scope.page).then (data) ->
      $scope.pushItemsOntoList data
      $scope.loading    = false
      totalItemsInList  = data.limits.total
      $scope.morePages  = ($scope.page * $scope.listService.perPage) < totalItemsInList      
      return

  $scope.loadCurrentPage()
]

app.controller "SearchController", [ "$scope", ($scope) ->
  # $scope.listService    = service that performs the search
  # $scope.setItemsOnList = pushes data onto list
  # $scope.emptyList      = clears the list

  $scope.search = {query: ""}

  $scope.performSearch = ->    
    if $scope.search.query.length > 2
      $scope.loading = true
      $scope.listService.search($scope.search.query).then (data) ->
        $scope.setItemsOnList data
        $scope.morePages  = false
        $scope.loading    = false
        return
    else
      $scope.emptyList()
      $scope.page       = 1
      $scope.morePages  = true
      $scope.loadCurrentPage()
]