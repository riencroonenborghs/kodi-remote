app = angular.module "kodiRemote.movies.services", []

app.service "Movies", [ "KodiRequest", (KodiRequest) ->
  service =
    perPage: 10
    index: (page = 1) -> 
      params =
        properties: ["plot", "year", "rating", "genre", "art", "tagline", "runtime"]
        sort:
          order: "ascending"
          method: "label"
        limits:
          start: (page - 1) * @perPage
          end: page * @perPage
      return KodiRequest.methodRequest "VideoLibrary.GetMovies", params      
    search: (query) ->
      params =
        properties: ["plot", "year", "rating", "genre", "art", "tagline", "runtime"]
        filter:
          field: "title"
          operator: "contains"
          value: query
      return KodiRequest.methodRequest "VideoLibrary.GetMovies", params
]