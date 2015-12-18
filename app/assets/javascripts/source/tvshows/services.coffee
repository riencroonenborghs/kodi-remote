app = angular.module "kodiRemote.tvshows.services", []

kodiRemote.parseImage = (image) ->
  return "" unless image
  image = decodeURIComponent image.replace("image://", "")
  return if image.endsWith("/") then image.slice(0, -1) else image

app.service "TvShows", [ "Request", "Seasons", (Request, Seasons) ->
  properties    = ["title", "genre", "year", "rating", "plot", "studio", "mpaa", "cast", "playcount", "episode", "imdbnumber", "premiered", "thumbnail", "season", "watchedepisodes"]
  
  allResultHandler = (result) ->
    for show in (result.tvshows || [])
      show.type = "tvShow"
      show.thumbnail = kodiRemote.parseImage show.thumbnail
      for castMember in show.cast
        castMember.thumbnail = kodiRemote.parseImage castMember.thumbnail
      show.seasons = -> Seasons.all @.tvshowid
    return result.tvshows || []

  getResultHandler = (result) ->
    result.tvshowdetails.type = "tvShow"
    result.tvshowdetails.thumbnail = kodiRemote.parseImage result.tvshowdetails.thumbnail
    for castMember in result.tvshowdetails.cast
      castMember.thumbnail = kodiRemote.parseImage castMember.thumbnail
    result.tvshowdetails.seasons = -> Seasons.all @.tvshowid
    return result.tvshowdetails

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
      season.thumbnail = kodiRemote.parseImage season.thumbnail
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
      episode.thumbnail = kodiRemote.parseImage episode.thumbnail
    return result.episodes || []

  getResultHandler = (result) -> 
    result.episodedetails.type = "episode"
    result.episodedetails.thumbnail = kodiRemote.parseImage result.episodedetails.thumbnail
    for castMember in result.episodedetails.cast
      castMember.thumbnail = kodiRemote.parseImage castMember.thumbnail
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