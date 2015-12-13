// Generated by CoffeeScript 1.9.3
(function() {
  var app,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    slice = [].slice;

  app = angular.module("kodiRemote.tvshows.services", []);

  app.service("TvShows", [
    "KodiRequest", function(KodiRequest) {
      var service;
      return service = {
        perPage: 10,
        index: function(page) {
          var params;
          if (page == null) {
            page = 1;
          }
          params = {
            properties: ["plot", "year", "rating", "genre", "art", "playcount"],
            sort: {
              order: "ascending",
              method: "label"
            },
            limits: {
              start: (page - 1) * this.perPage,
              end: page * this.perPage
            }
          };
          return KodiRequest.methodRequest("VideoLibrary.GetTVShows", params);
        },
        show: function(tvShowId) {
          return KodiRequest.methodRequest("VideoLibrary.GetTVShowDetails", {
            tvshowid: tvShowId
          });
        },
        search: function(query) {
          var params;
          params = {
            properties: ["plot", "year", "rating", "genre", "art", "playcount"],
            filter: {
              field: "title",
              operator: "contains",
              value: query
            }
          };
          return KodiRequest.methodRequest("VideoLibrary.GetTVShows", params);
        },
        Seasons: {
          index: function(tvShowId) {
            var params;
            params = {
              properties: ["playcount"],
              tvshowid: tvShowId
            };
            return KodiRequest.methodRequest("VideoLibrary.GetSeasons", params);
          },
          Episodes: {
            index: function(tvShowId, season) {
              var params;
              params = {
                tvshowid: tvShowId,
                season: season,
                properties: ["title", "plot", "rating", "runtime", "art", "thumbnail", "playcount", "file"]
              };
              return KodiRequest.methodRequest("VideoLibrary.GetEpisodes", params);
            },
            prepDownload: function(filePath) {
              return KodiRequest.methodRequest("Files.PrepareDownload", [filePath]);
            }
          }
        }
      };
    }
  ]);

  app.service("TvShowsLoader", [
    "TvShows", "SERVER", "PORT", function(TvShows, SERVER, PORT) {
      var Downloader, SeasonsLoader, TvShowDetailsLoader, service;
      service = {
        DetailsLoader: TvShowDetailsLoader = (function(superClass) {
          extend(TvShowDetailsLoader, superClass);

          function TvShowDetailsLoader(scope) {
            this.scope = scope;
            TvShowDetailsLoader.__super__.constructor.call(this, this.scope, TvShows);
          }

          TvShowDetailsLoader.prototype.handleData = function(data) {
            return this.scope.tvShowDetails = data.tvshowdetails;
          };

          return TvShowDetailsLoader;

        })(kodiRemote.Loader),
        SeasonsLoader: SeasonsLoader = (function(superClass) {
          extend(SeasonsLoader, superClass);

          function SeasonsLoader(scope) {
            this.scope = scope;
            SeasonsLoader.__super__.constructor.call(this, this.scope, TvShows.Seasons);
          }

          SeasonsLoader.prototype.handleData = function(data) {
            return this.scope.list = data.seasons;
          };

          return SeasonsLoader;

        })(kodiRemote.Loader),
        EpisodesLoader: SeasonsLoader = (function(superClass) {
          extend(SeasonsLoader, superClass);

          function SeasonsLoader(scope) {
            this.scope = scope;
            SeasonsLoader.__super__.constructor.call(this, this.scope, TvShows.Seasons.Episodes);
          }

          SeasonsLoader.prototype.handleData = function(data) {
            return this.scope.episodes = data.episodes;
          };

          return SeasonsLoader;

        })(kodiRemote.Loader),
        EpisodeDownloader: Downloader = (function(superClass) {
          extend(Downloader, superClass);

          function Downloader(scope) {
            this.scope = scope;
            Downloader.__super__.constructor.call(this, this.scope, TvShows.Seasons.Episodes);
          }

          Downloader.prototype.handleData = function(data) {
            var path;
            path = encodeURI(decodeURIComponent(data.details.path));
            return this.scope.url = data.protocol + "://" + SERVER + ":" + PORT + "/" + path;
          };

          Downloader.prototype.prepDownload = function() {
            var params, ref;
            params = 1 <= arguments.length ? slice.call(arguments, 0) : [];
            return (ref = this.service).prepDownload.apply(ref, params).then((function(_this) {
              return function(data) {
                return _this.handleData(data);
              };
            })(this));
          };

          return Downloader;

        })(kodiRemote.Loader)
      };
      return service;
    }
  ]);

}).call(this);