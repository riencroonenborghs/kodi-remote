app = angular.module "kodiRemote.genres.services", []

app.service "Genres", [ "Request", (Request) ->
  tvShowProperties = ["title", "genre", "year", "rating", "plot", "studio", "mpaa", "cast", "playcount", "episode", "imdbnumber", "premiered", "thumbnail", "season", "watchedepisodes"]
  movieProperties = ["title", "genre", "year", "rating", "director", "tagline", "plot", "plotoutline", "playcount", "writer", "studio", "mpaa", "cast", "imdbnumber", "runtime", "thumbnail", "resume"]

  allResultHandler = (result) -> return result.genres || []

  getResultHandler = (type, result) ->
    for show in (result[type] || [])
      show.type = "tvShow"
      show.thumbnail = kodiRemote.imageObject show.thumbnail
      for castMember in show.cast
        castMember.thumbnail = kodiRemote.imageObject castMember.thumbnail
      show.seasons = -> Seasons.all @.tvshowid
    return result[type] || []
  getTvShowsResultHandler = (result) ->
    getResultHandler "tvshows", result
  getMoviesResultHandler = (result) ->
    getResultHandler "movies", result

  service =
    all: (type) ->
      params =        
        properties: ["title"]
        sort:
          method: "title"
          order: "ascending"
      if type != "music"
        params.type = type
        return Request.fetch "VideoLibrary.GetGenres", allResultHandler, params
      else
        return Request.fetch "AudioLibrary.GetGenres", allResultHandler, params

    get: (type, genre, sortDirection) ->
      params =
        sort:
          method: "title"
          order: sortDirection
        filter:
            field: "genre"
            operator: "is"
            value: genre

      switch type
        when "tvshows"
          params.properties = tvShowProperties
          return Request.fetch "VideoLibrary.GetTVShows", getTvShowsResultHandler, params
        when "movies"
          params.properties = movieProperties
          return Request.fetch "VideoLibrary.GetMovies", getMoviesResultHandler, params


  service
]