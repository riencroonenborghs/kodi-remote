app = angular.module "kodiRemote.tvshows.services", []

app.service "TvShows", [ "KodiRequest", (KodiRequest) ->
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
      return KodiRequest.methodRequest "VideoLibrary.GetTVShows", params
    show: (tvShowId) ->
      return KodiRequest.methodRequest "VideoLibrary.GetTVShowDetails", {tvshowid: tvShowId}
    search: (query) ->
      params =
        properties: ["plot", "year", "rating", "genre", "art", "playcount"]
        filter:
          field: "title"
          operator: "contains"
          value: query
      return KodiRequest.methodRequest "VideoLibrary.GetTVShows", params
    Seasons: 
      index: (tvShowId) -> 
        params =
          properties: ["playcount"]
          tvshowid: tvShowId
        return KodiRequest.methodRequest "VideoLibrary.GetSeasons", params
      Episodes: 
        index: (tvShowId, season) ->
          params =
            tvshowid: tvShowId
            season: season
            properties: ["title", "plot", "rating", "runtime", "art", "thumbnail", "playcount", "file"]
          return KodiRequest.methodRequest "VideoLibrary.GetEpisodes", params
        prepDownload: (filePath) ->
          return KodiRequest.methodRequest "Files.PrepareDownload", [filePath]
]

app.service "TvShowsLoader", [ "TvShows", "SERVER", "PORT", (TvShows, SERVER, PORT) ->
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

    EpisodeDownloader: class Downloader extends kodiRemote.Loader
      constructor: (@scope) ->
        super @scope, TvShows.Seasons.Episodes
      handleData: (data) ->
        path = encodeURI decodeURIComponent(data.details.path)
        @scope.url = "#{data.protocol}://#{SERVER}:#{PORT}/#{path}"
      prepDownload: (params...) -> 
        @service.prepDownload(params...).then (data) => 
          @handleData data

  service
]