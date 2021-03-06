var app;

app = angular.module("kodiRemote.playlist.services", []);

app.service("Playlist", [
  "Request", function(Request) {
    var emptyHandler, itemsHandler, service;
    emptyHandler = function() {};
    itemsHandler = function(result) {
      var i, item, len, ref;
      ref = result.items || [];
      for (i = 0, len = ref.length; i < len; i++) {
        item = ref[i];
        item.thumbnail = kodiRemote.imageObject(item.thumbnail);
      }
      return result.items || [];
    };
    service = {
      playlistId: 1,
      clear: function() {
        var params;
        params = [this.playlistId];
        return Request.fetch("Playlist.Clear", emptyHandler, params);
      },
      remove: function(index) {
        var params;
        params = [this.playlistId, index];
        return Request.fetch("Playlist.Remove", emptyHandler, params);
      },
      addEpisode: function(episodeId) {
        var params;
        params = [
          this.playlistId, {
            episodeid: episodeId
          }
        ];
        return Request.fetch("Playlist.Add", emptyHandler, params);
      },
      addMovie: function(movieId) {
        var params;
        params = [
          this.playlistId, {
            movieid: movieId
          }
        ];
        return Request.fetch("Playlist.Add", emptyHandler, params);
      },
      addChannel: function(channelId) {
        var params;
        params = [
          this.playlistId, {
            channelid: channelId
          }
        ];
        return Request.fetch("Playlist.Add", emptyHandler, params);
      },
      items: function() {
        var params, properties;
        properties = ["title", "showtitle", "playcount", "season", "episode", "thumbnail", "tvshowid", "uniqueid", "art"];
        params = {
          playlistid: this.playlistId,
          properties: properties
        };
        return Request.fetch("Playlist.GetItems", itemsHandler, params);
      }
    };
    return service;
  }
]);
