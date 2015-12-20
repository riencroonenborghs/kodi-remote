app = angular.module "kodiRemote.music.controllers", []

app.controller "AlbumsController", [ "$scope", "NavbarFactory", "Albums", ($scope, NavbarFactory, Albums) ->  
  $scope.albums = []  

  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad  before load

  $scope.beforeSortLoad = ->
    $scope.albums = []
    $scope.pagination.page = 1

  # autoScrollPaginate directive
  # - sets $scope.pagination hash
  # - uses $scope.paginationAfterLoad to calculate $scope.pagination.more
  # - uses $scope.loading

  $scope.load = ->
    $scope.loading = true
    Albums.all($scope.pagination.page, $scope.sortParams).then (data) ->      
      $scope.loading = false
      for album in data.data
        $scope.albums.push album
      $scope.Navbar = new NavbarFactory
      $scope.Navbar.addTitle "Albums (#{data.total})"
      $scope.paginationAfterLoad Albums.perPage, data.total
      return
]