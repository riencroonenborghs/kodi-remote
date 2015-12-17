app = angular.module "kodiRemote.movies.controllers", []

app.controller "MoviesController", [ "$scope", "Topbar", "Movies", ($scope, Topbar, Movies) ->  
  Topbar.setTitle "Movies"

  $scope.movies = []

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
      Topbar.setTitle "Movies (#{data.total})"
      $scope.paginationAfterLoad Movies.perPage, data.total
      return

  
]

app.controller "MovieController", [ "$scope", "$routeParams", "Movies", "Topbar", 
($scope, $routeParams, Movies, Topbar) ->
  movieId = parseInt $routeParams.id

  $scope.movie = null

  Movies.get(movieId).then (movieData) ->
    $scope.movie = movieData.data
    Topbar.setLink "/movies", $scope.movie.title
]