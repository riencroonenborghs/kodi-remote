app = angular.module "kodiRemote.movies.services", []

app.service "Movies", [ "KodiRequest", (KodiRequest) ->
  movieProperties = ["plot", "year", "rating", "genre", "art", "tagline", "runtime", "playcount"]

  service =
    perPage: 10
    index: (page = 1, sortBy = "label", sortDirection = "ascending") -> 
      params =
        properties: movieProperties
        sort:
          method: sortBy
          order: sortDirection
        limits:
          start: (page - 1) * @perPage
          end: page * @perPage
      return KodiRequest.methodRequest "VideoLibrary.GetMovies", params
    show: (movieId) ->
      properties = ["cast", "fanart", "director", "writer", "studio", "mpaa"]
      return KodiRequest.methodRequest "VideoLibrary.GetMovieDetails", {movieid: movieId, properties: properties}
    Search: 
      query: (query) ->
        params =
          properties: movieProperties
          filter:
            field: "title"
            operator: "contains"
            value: query
        return KodiRequest.methodRequest "VideoLibrary.GetMovies", params
      genre: (genre) ->
        params =
          properties: movieProperties
          filter:
            field: "genre"
            operator: "is"
            value: genre
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