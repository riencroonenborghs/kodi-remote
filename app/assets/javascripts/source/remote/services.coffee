app = angular.module "kodiRemote.remote.services", []

app.service "RemoteControl", [ "KodiRequest", (KodiRequest) ->
  service =    
    up: -> return KodiRequest.methodRequest "Input.Up", {}
    down: -> return KodiRequest.methodRequest "Input.Down", {}
    left: -> return KodiRequest.methodRequest "Input.Left", {}
    right: -> return KodiRequest.methodRequest "Input.Right", {}
    home: -> return KodiRequest.methodRequest "Input.Home", {}
    select: -> return KodiRequest.methodRequest "Input.Select", {}
    back: -> return KodiRequest.methodRequest "Input.Back", {}
    scanLibrary: -> return KodiRequest.methodRequest "VideoLibrary.Scan", {}
    info: -> return KodiRequest.methodRequest "Input.Info", {}
]