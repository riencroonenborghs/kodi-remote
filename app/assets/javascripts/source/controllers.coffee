app = angular.module "kodiRemote.controllers", []

app.controller "AppController", [ "$scope", "Topbar", "$location", ($scope, Topbar, $location) ->
  Topbar.reset()
  Topbar.addTitle "Kodi Remote"
  $scope.Topbar = Topbar

  $scope.visit = (path) -> $location.path path
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