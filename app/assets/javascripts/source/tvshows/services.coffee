app = angular.module "kodiRemote.tvshows.services", []

app.service "TvShows", [ "Remote", (Remote) ->
  service =
    perPage: 10
    index: (page = 1) -> 
      params =
        properties: ["plot", "year", "rating", "genre", "art"]
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
        properties: ["plot", "year", "rating", "genre", "art"]
        filter:
          field: "title"
          operator: "contains"
          value: query
      return Remote.methodRequest "VideoLibrary.GetTVShows", params
    Seasons: 
      index: (tvShowId) -> return Remote.methodRequest "VideoLibrary.GetSeasons", {tvshowid: tvShowId}
    Episodes: 
      index: (tvShowId) ->
        params =
          tvshowid: tvShowId
          season: seasonId
          properties: ["title", "plot", "rating", "runtime", "art", "thumbnail"]
        return Remote.methodRequest "VideoLibrary.GetEpisodes", params
]