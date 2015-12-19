app = angular.module "kodiRemote.movies.controllers", []

app.controller "MoviesController", [ "$scope", "NavbarFactory", "Movies", "Remote", 
($scope, NavbarFactory, Movies, Remote) ->  
  $scope.movies = []
  $scope.movieGroups = []

  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad  before load

  $scope.beforeSortLoad = ->
    $scope.movies = []
    $scope.pagination.page = 1

  # autoScrollPaginate directive
  # - sets $scope.pagination hash
  # - uses $scope.paginationAfterLoad to calculate $scope.pagination.more
  # - uses $scope.loading

  $scope.load = ->
    $scope.loading = true
    Movies.all($scope.pagination.page, $scope.sortParams).then (data) ->
      $scope.loading = false
      for movie in data.data
        $scope.movies.push movie

      $scope.movieGroups = kodiRemote.array.inGroupsOf $scope.movies, 2
      $scope.Navbar = new NavbarFactory
      $scope.Navbar.addTitle "Movies (#{data.total})"
      $scope.paginationAfterLoad Movies.perPage, data.total
      return

  # $scope.showPlayButton = (event) -> 
  #   $(event.currentTarget).find(".hoverable-video-avatar").find("button").show()
  # $scope.hidePlayButton = (event) -> 
  #   $(event.currentTarget).find(".hoverable-video-avatar").find("button").hide()
  
]

app.controller "MovieController", [ "$scope", "$routeParams", "Movies", "NavbarFactory", 
($scope, $routeParams, Movies, NavbarFactory) ->
  movieId = parseInt $routeParams.id

  $scope.movie = null

  Movies.get(movieId).then (movieData) ->
    $scope.movie = movieData.data
    $scope.Navbar = new NavbarFactory
    $scope.Navbar.addLink "/movies", "Movies"
    $scope.Navbar.addTitle $scope.movie.title
]