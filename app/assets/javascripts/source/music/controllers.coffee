app = angular.module "kodiRemote.music.controllers", []

app.controller "AlbumsController", [ "$scope", "$rootScope", "NavbarFactory", "Albums", 
($scope, $rootScope, NavbarFactory, Albums) ->  
  $scope.albums = []
  $scope.albumGroups = []

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
    $rootScope.$broadcast "topbar.loading", true
    $scope.loading = true
    Albums.all($scope.pagination.page, $scope.sortParams).then (data) ->    
      $rootScope.$broadcast "topbar.loading", false
      $scope.loading = false
      for album in data.data
        $scope.albums.push album
      $scope.albumGroups = kodiRemote.array.inGroupsOf $scope.albums, 2      
      $scope.Navbar = new NavbarFactory
      $scope.Navbar.addTitle "Albums (#{data.total})"
      $scope.paginationAfterLoad Albums.perPage, data.total
      return
]