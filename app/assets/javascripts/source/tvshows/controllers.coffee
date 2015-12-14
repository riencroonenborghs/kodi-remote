app = angular.module "kodiRemote.tvshows.controllers", []

app.controller "TvShowsController", [ "$scope", "$controller", "Topbar", "TvShows", ($scope, $controller, Topbar, TvShows) ->  
  Topbar.setTitle "TV Shows"

  $scope.listService = TvShows
  $scope.pushItemsOntoList = (data) ->
    for tvShow in data.tvshows
      $scope.list.push tvShow
    Topbar.setTitle "TV Shows (#{data.limits.total})"
  $controller "PaginatedController", {$scope: $scope}

  $scope.setItemsOnList = (data) -> $scope.list = data.tvshows
  $scope.emptyList = -> $scope.list = []
  $controller "SearchController", {$scope: $scope}

  # $scope.visitSeasons = (tvShowId) -> $scope.visit("/tvshows/#{tvShowId}/seasons")
]

app.controller "TvShowSeasonsController", [ "$scope", "$routeParams", "$controller", "Topbar", "TvShowsLoader", 
($scope, $routeParams, $controller, Topbar, TvShowsLoader) ->  
  $scope.tvShowId = parseInt $routeParams.id

  $scope.visitEpisodes = (tvShowId, seasonId) ->
    $scope.visit("/tvshows/#{tvShowId}/seasons/#{seasonId}/episodes")

  detailsLoader = new TvShowsLoader.DetailsLoader $scope
  detailsLoader.afterCallback = (data) -> Topbar.setLink "/tvshows", $scope.tvShowDetails.label
  detailsLoader.show $scope.tvShowId

  seasonsLoader = new TvShowsLoader.SeasonsLoader $scope
  seasonsLoader.index $scope.tvShowId
]

app.controller "TvShowSeasonEpisodesController", [ "$scope", "$routeParams", "Topbar", "TvShowsLoader", "Remote",
($scope, $routeParams, Topbar, TvShowsLoader, Remote) ->  
  $scope.tvShowId = parseInt $routeParams.tvshowid  
  $scope.seasonId = parseInt $routeParams.id

  detailsLoader = new TvShowsLoader.DetailsLoader $scope
  detailsLoader.show $scope.tvShowId

  seasonsLoader = new TvShowsLoader.SeasonsLoader $scope
  seasonsLoader.afterCallback = (data) ->
    for season in data.seasons
      if season.seasonid == $scope.seasonId
        if season.label == "Specials"
          $scope.seasonNumber = 0
        else  
          $scope.seasonNumber = parseInt season.label.match(/(\d)/)[0]
        Topbar.setLink "/tvshows/#{$scope.tvShowId}/seasons", season.label
  seasonsLoader.index $scope.tvShowId

  $scope.$watch "seasonNumber", ->    
    if $scope.seasonNumber != null
      episodesLoader = new TvShowsLoader.EpisodesLoader $scope
      episodesLoader.index $scope.tvShowId, $scope.seasonNumber

  $scope.play = (episode) -> Remote.playEpisode(episode.episodeid)
  
  # $scope.download = (episode) -> 
  #   $scope.url = null
  #   fileName = "#{$scope.tvShowDetails.label} - #{episode.title}.mp4"
  #   episodeDownloader = new TvShowsLoader.EpisodeDownloader $scope
  #   episodeDownloader.prepDownload episode.file

  #   downloadFile = (url, success) ->
  #     xhr = new XMLHttpRequest()
  #     xhr.open "GET", url, true
  #     xhr.responseType = "blob"
  #     xhr.onreadystatechange = ->
  #       if xhr.readyState == 4
  #         success xhr.response
  #     xhr.send null

    
  #   $scope.$watch "url", ->
  #     if $scope.url
  #       downloadFile $scope.url, (data) ->
  #         saveAs data, fileName

  #   # TvShows.Seasons.Episodes.prepDownload(episode.file).then (data) ->
  #   #   path = encodeURI decodeURIComponent(data.details.path)
  #   #   url = "#{data.protocol}://#{SERVER}:#{PORT}/#{path}"
  #   #   console.debug url

]