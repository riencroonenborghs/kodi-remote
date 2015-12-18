app = angular.module "kodiRemote.tvshows.services", []

app.service "TvShows", [ "Request", "Seasons", (Request, Seasons) ->
  properties    = ["title", "genre", "year", "rating", "plot", "studio", "mpaa", "cast", "playcount", "episode", "imdbnumber", "premiered", "thumbnail", "season", "watchedepisodes"]
  
  allResultHandler = (result) ->
    for show in (result.tvshows || [])
      show.type = "tvShow"
      show.seasons = -> Seasons.all @.tvshowid
    return result.tvshows || []

  getResultHandler = (result) ->
    result.tvshowdetails.type = "tvShow"
    result.tvshowdetails.seasons = -> Seasons.all @.tvshowid
    return result.tvshowdetails

  service = 
    perPage: 5

    where:
      title: (query) ->
        params =
          properties: properties
          filter:
            field: "title"
            operator: "contains"
            value: query
         
        return Request.fetch "VideoLibrary.GetTVShows", allResultHandler, params

    all: (pageParams = 1, sortParams = {by: "label", direction: "ascending"}) -> 
      params =
        properties: properties
        sort:
          method: sortParams.by
          order: sortParams.direction
        limits:
          start: (pageParams - 1) * @perPage
          end: pageParams * @perPage
       
      return Request.fetch "VideoLibrary.GetTVShows", allResultHandler, params

    get: (tvShowId) ->
      params =
        tvshowid: tvShowId
        properties: properties
               
      return Request.fetch "VideoLibrary.GetTVShowDetails", getResultHandler, params

    
  service
]

app.service "Seasons", [ "Request", "Episodes", (Request, Episodes) ->
  properties    = ["season", "playcount", "episode", "thumbnail", "tvshowid", "watchedepisodes"]

  resultHandler = (result) ->
    for season in (result.seasons || [])
      season.type = "season"
      season.episodes = -> Episodes.all @.tvshowid, @.season
    return result.seasons || []

  service = 
    all: (tvShowId) -> 
      params =
        tvshowid: tvShowId
        properties: properties
            
      return Request.fetch "VideoLibrary.GetSeasons", resultHandler, params
    
  service
]

app.service "Episodes", [ "Request", (Request) ->
  properties    = ["title", "plot", "rating", "writer", "firstaired", "playcount", "runtime", "director", "season", "episode", "cast", "thumbnail", "resume", "showtitle", "tvshowid"]
  
  resultHandler = (result) -> 
    for episode in (result.episodes || [])
      episode.type = "episode"
    return result.episodes || []

  getResultHandler = (result) -> 
    result.episodedetails.type = "episode"
    result.episodedetails

  service = 
    all: (tvShowId, season) -> 
      params =
        tvshowid: tvShowId
        season: season
        properties: properties
      return Request.fetch "VideoLibrary.GetEpisodes", resultHandler, params

    get: (episodeId) ->
      params =
        episodeid: episodeId
        properties: properties
               
      return Request.fetch "VideoLibrary.GetEpisodeDetails", getResultHandler, params
    
  service
]