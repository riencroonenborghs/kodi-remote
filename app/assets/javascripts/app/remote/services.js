var app;

app = angular.module("kodiRemote.remote.services", []);

app.service("Player", [
  "$rootScope", "Request", "Playlist", function($rootScope, Request, Playlist) {
    var emptyHandler, returnHandler, service;
    emptyHandler = function(data) {};
    returnHandler = function(data) {
      return data;
    };
    service = {
      activePlayers: function() {
        return Request.fetch("Player.GetActivePlayers", returnHandler, {});
      },
      playing: function(playerId) {
        var params;
        params = {
          playerid: playerId,
          properties: ["title", "showtitle", "year", "runtime", "season", "episode", "streamdetails", "albumartist", "track", "album", "albumlabel", "duration"]
        };
        return Request.fetch("Player.GetItem", returnHandler, params);
      },
      open: function(playlistId, position) {
        var params;
        $rootScope.$broadcast("playlist.reload");
        params = [
          {
            playlistid: playlistId,
            position: position
          }, {
            resume: true
          }
        ];
        return Request.fetch("Player.Open", emptyHandler, params);
      },
      stop: function() {
        return Request.fetch("Player.Stop", emptyHandler, [1]);
      },
      playPause: function(playerId) {
        return Request.fetch("Player.PlayPause", emptyHandler, [playerId]);
      },
      properties: function(playerId) {
        return Request.fetch("Player.GetProperties", returnHandler, [playerId, ["percentage", "time", "subtitles", "audiostreams", "subtitleenabled"]]);
      },
      setSubtitle: function(playerId, subtitle) {
        return Request.fetch("Player.SetSubtitle", emptyHandler, [playerId, subtitle]);
      },
      setAudioStream: function(playerId, audiostream) {
        return Request.fetch("Player.SetAudioStream", emptyHandler, [playerId, audiostream]);
      },
      seek: function(playerId, percentage) {
        return Request.fetch("Player.Seek", emptyHandler, [playerId, percentage]);
      },
      playEpisode: function(episodeId) {
        return this.stop().then((function(_this) {
          return function() {
            return Playlist.clear().then(function() {
              return Playlist.addEpisode(episodeId).then(function() {
                return _this.open(1, 0);
              });
            });
          };
        })(this));
      },
      playMovie: function(movieId) {
        return this.stop().then((function(_this) {
          return function() {
            return Playlist.clear().then(function() {
              return Playlist.addMovie(movieId).then(function() {
                return _this.open(1, 0);
              });
            });
          };
        })(this));
      }
    };
    return service;
  }
]);

app.service("Remote", [
  "Request", function(Request) {
    var emptyHandler, service;
    emptyHandler = function(data) {};
    service = {
      up: function() {
        return Request.fetch("Input.Up", emptyHandler, {});
      },
      down: function() {
        return Request.fetch("Input.Down", emptyHandler, {});
      },
      left: function() {
        return Request.fetch("Input.Left", emptyHandler, {});
      },
      right: function() {
        return Request.fetch("Input.Right", emptyHandler, {});
      },
      home: function() {
        return Request.fetch("Input.Home", emptyHandler, {});
      },
      select: function() {
        return Request.fetch("Input.Select", emptyHandler, {});
      },
      back: function() {
        return Request.fetch("Input.Back", emptyHandler, {});
      },
      scanLibrary: function() {
        return Request.fetch("VideoLibrary.Scan", emptyHandler, {});
      },
      info: function() {
        return Request.fetch("Input.Info", emptyHandler, {});
      },
      clean: function() {
        return Request.fetch("VideoLibrary.Clean", emptyHandler, {});
      },
      contextMenu: function() {
        return Request.fetch("Input.ContextMenu", emptyHandler, {});
      }
    };
    return service;
  }
]);
