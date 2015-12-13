app = angular.module "kodiRemote.tvshows.services", []

app.service "TvShows", [ "Remote", (Remote) ->
  service =
    perPage: 10
    index: (page = 1) -> 
      params =
        properties: ["plot", "year", "rating", "genre", "art", "playcount"]
        sort:
          order: "ascending"
          method: "label"
        limits:
          start: (page - 1) * @perPage
          end: page * @perPage
      return Remote.methodRequest "VideoLibrary.GetTVShows", params
    show: (tvShowId) ->
      return Remote.methodRequest "VideoLibrary.GetTVShowDetails", {tvshowid: tvShowId}
    search: (query) ->
      params =
        properties: ["plot", "year", "rating", "genre", "art", "playcount"]
        filter:
          field: "title"
          operator: "contains"
          value: query
      return Remote.methodRequest "VideoLibrary.GetTVShows", params
    Seasons: 
      index: (tvShowId) -> 
        params =
          properties: ["playcount"]
          tvshowid: tvShowId
        return Remote.methodRequest "VideoLibrary.GetSeasons", params
      Episodes: 
        index: (tvShowId, season) ->
          params =
            tvshowid: tvShowId
            season: season
            properties: ["title", "plot", "rating", "runtime", "art", "thumbnail", "playcount"]
          return Remote.methodRequest "VideoLibrary.GetEpisodes", params
]

app.service "TvShowsLoader", [ "TvShows", (TvShows) ->
  service =
    DetailsLoader: class TvShowDetailsLoader extends kodiRemote.Loader
      constructor: (@scope) ->
        super @scope, TvShows
      handleData: (data) -> 
        @scope.tvShowDetails = data.tvshowdetails

    SeasonsLoader: class SeasonsLoader extends kodiRemote.Loader
      constructor: (@scope) ->
        super @scope, TvShows.Seasons
      handleData: (data) -> @scope.list = data.seasons

    EpisodesLoader: class SeasonsLoader extends kodiRemote.Loader
      constructor: (@scope) ->
        super @scope, TvShows.Seasons.Episodes
      handleData: (data) -> @scope.episodes = data.episodes
  service
]