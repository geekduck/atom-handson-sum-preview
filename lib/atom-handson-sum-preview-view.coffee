{View} = require 'space-pen'

module.exports =
  class AtomHandsonSumPreviewView extends View
    @content: ->
      @div class: 'atom-handson-sum-preview', =>
        @div outlet: "container"

    constructor: ({@editorId}) ->
      super
      @container.html "Hello World #{@editorId}"

    getTitle: ->
      "#{@editorId} Sum Preview"

    getURI: ->
      "atom-handson-sum-preview://editor/#{@editorId}" if @editorId?
