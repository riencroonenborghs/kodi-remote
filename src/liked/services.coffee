app = angular.module "kodiRemote.liked.services", []

app.service "Liked", [ ->
  service =
    addTvShow: (tvShow) ->
      return if tvShow.tvshowid in kodiRemote.settings.liked.tvShows
      kodiRemote.settings.liked.tvShows.push tvShow.tvshowid
      tvShow.liked = true
      @_save()
      return
    removeTvShow: (tvShow) ->
      return unless tvShow.tvshowid in kodiRemote.settings.liked.tvShows
      kodiRemote.settings.liked.tvShows.splice kodiRemote.settings.liked.tvShows.indexOf(tvShow.tvshowid), 1
      tvShow.liked = false
      @_save()
      return
    toggleTvShow: (tvShow) ->
      if tvShow.tvshowid in kodiRemote.settings.liked.tvShows
        @removeTvShow tvShow
      else
        @addTvShow tvShow

    _save: ->
      chrome.storage.local.clear()
      hash =
        server: kodiRemote.settings.server
        port: kodiRemote.settings.port
        requestType: kodiRemote.settings.requestType
        liked:
          tvShows: kodiRemote.settings.liked.tvShows
          # tvShows: []
          movies: kodiRemote.settings.liked.movies
      data = JSON.stringify hash
      chrome.storage.local.set {kodiRemote: data}

  service
]