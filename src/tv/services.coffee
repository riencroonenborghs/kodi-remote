app = angular.module "kodiRemote.tv.services", []

app.service "TVChannels", [ "Request", (Request) ->
  getTVChannelGroup = ->
    params =
      channeltype: "tv"
    Request.fetch("PVR.GetChannelGroups", ((data) -> data.channelgroups[0]), params)

  service =
    all: ->
      getTVChannelGroup().then (group) ->
        params =
          properties: ["thumbnail", "channel", "broadcastnow", "broadcastnext", "icon", "channelnumber"]
          channelgroupid: group.data.channelgroupid
        Request.fetch("PVR.GetChannels", ((data) -> data.channels), params)

  service
]