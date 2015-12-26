app = angular.module "kodiRemote.movies.services", []

app.service "Movies", [ "Request", (Request) ->
  properties = ["title", "genre", "year", "rating", "director", "tagline", "plot", "plotoutline", "playcount", "writer", "studio", "mpaa", "cast", "imdbnumber", "runtime", "thumbnail", "resume"]

  allResultHandler = (result) -> 
    for movie in (result.movies || [])
      movie.type = "movie"
      movie.thumbnail = kodiRemote.parseImage movie.thumbnail
    return result.movies || []

  getResultHandler = (result) -> 
    result.moviedetails.type = "movie"
    result.moviedetails.thumbnail = kodiRemote.parseImage result.moviedetails.thumbnail
    for castMember in result.moviedetails.cast
      castMember.thumbnail = kodiRemote.parseImage castMember.thumbnail
    result.moviedetails

  yearsResultHandler = (result) -> return result.movies || []

  service = 
    perPage: 10

    where:
      title: (query) ->
        params =
          properties: properties
          filter:
            field: "title"
            operator: "contains"
            value: query
        return Request.fetch "VideoLibrary.GetMovies", allResultHandler, params    

    all: (pageParams = 1, sortParams = {by: "label", direction: "ascending"}) -> 
      params =
        properties: properties
        sort:
          method: sortParams.by
          order: sortParams.direction
        limits:
          start: (pageParams - 1) * @perPage
          end: pageParams * @perPage
      return Request.fetch "VideoLibrary.GetMovies", allResultHandler, params

    recentlyAdded: ->
      params =
        properties: properties
      return Request.fetch "VideoLibrary.GetRecentlyAddedMovies", allResultHandler, params

    get: (movieId) ->
      params =
        movieid: movieId
        properties: properties
      return Request.fetch "VideoLibrary.GetMovieDetails", getResultHandler, params

    years: -> 
      params =
        properties: ["year"]
      return Request.fetch "VideoLibrary.GetMovies", yearsResultHandler, params

    year: (year, pageParams = 1) -> 
      params =
        properties: properties
        filter:
          field: "year"
          operator: "is"
          value: "#{year}"
        limits:
            start: (pageParams - 1) * @perPage
            end: pageParams * @perPage
      return Request.fetch "VideoLibrary.GetMovies", allResultHandler, params
    
  service
]