var app;

app = angular.module("kodiRemote.tv.services", []);

app.service("TVChannels", [
  "Request", function(Request) {
    var getTVChannelGroup, service;
    getTVChannelGroup = function() {
      var params;
      params = {
        channeltype: "tv"
      };
      return Request.fetch("PVR.GetChannelGroups", (function(data) {
        return data.channelgroups[0];
      }), params);
    };
    service = {
      all: function() {
        return getTVChannelGroup().then(function(group) {
          var params;
          params = {
            properties: ["thumbnail", "channel", "broadcastnow", "broadcastnext", "icon", "channelnumber"],
            channelgroupid: group.data.channelgroupid
          };
          return Request.fetch("PVR.GetChannels", (function(data) {
            return data.channels;
          }), params);
        });
      }
    };
    return service;
  }
]);
