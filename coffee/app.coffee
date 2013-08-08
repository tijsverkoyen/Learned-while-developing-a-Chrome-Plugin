class DefaultObject
  # Class methods
  @events: (events) ->
    @::events ?= {}
    @::events = $.extend({}, @::events) unless @::hasOwnProperty "events"
    @::events = $.extend(true, {}, @::events, events)

  @onDomReady: (initializers) ->
    @::onDomReady ?= []
    @::onDomReady = @::onDomReady[..] unless @::hasOwnProperty "onDomReady"
    @::onDomReady.push initializer for initializer in initializers

  constructor: ->
    @_setupEventListeners()

  domReady: ->
    @_loadOnDomReadyMethods()

  _loadOnDomReadyMethods: ->
    for callback in @onDomReady
      @[callback]()

  _setupEventListeners: =>
    $document = $(document)
    for selector, actions of @events
      for action, callback of actions
        $document.on(action, selector, @[callback])

class App extends DefaultObject
  @events
    '#pingTheSite' : click : '_pingTheSite'
    '#pingTheIframe' : click : '_pingTheIframe'

  @onDomReady [
    '_initEventListeners'
  ]

  _initEventListeners: ->
    if $('body').hasClass('site')
      window.addEventListener('message', @_siteMessageHandler, false);
    if $('body').hasClass('iframe')
      window.addEventListener('message', @_iframeMessageHandler, false);

  _pingTheSite: (e) ->
    console.log 'ping the site'

    top.postMessage(
      { message: 'ping from the iframe', 'source': 'button' },
      'http://demo.tijs.dev' # replace with your url
    );

  _pingTheIframe: (e) ->
    console.log 'ping the iframe'
  _siteMessageHandler: (e) ->
    console.log 'message received on the site'
  _iframeMessageHandler: (e) ->
    console.log 'message received on the iframe'
App.current = new App()

$ ->
  App.current.domReady()

window.App = App
