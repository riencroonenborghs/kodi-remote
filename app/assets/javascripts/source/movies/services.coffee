app = angular.module "kodiRemote.movies.services", []

app.service "Movies", [ "KodiRequest", (KodiRequest) ->
  service =
    perPage: 10
    index: (page = 1) -> 
      params =
        properties: ["plot", "year", "rating", "genre", "art", "tagline", "runtime", "playcount"]
        sort:
          order: "ascending"
          method: "label"
        limits:
          start: (page - 1) * @perPage
          end: page * @perPage
      return KodiRequest.methodRequest "VideoLibrary.GetMovies", params      
    show: (movieId) ->
      properties = ["cast", "fanart", "director", "writer", "studio", "mpaa"]
      return KodiRequest.methodRequest "VideoLibrary.GetMovieDetails", {movieid: movieId, properties: properties}
    search: (query) ->
      params =
        properties: ["plot", "year", "rating", "genre", "art", "tagline", "runtime", "playcount"]
        filter:
          field: "title"
          operator: "contains"
          value: query
      return KodiRequest.methodRequest "VideoLibrary.GetMovies", params
]

app.service "MoviesLoader", [ "Movies", (Movies) ->
  service =
    DetailsLoader: class MovieDetailsLoader extends kodiRemote.Loader
      constructor: (@scope) ->
        super @scope, Movies
      handleData: (data) -> 
        @scope.movieDetails = data.moviedetails

  service
]