AtomHandsonSumPreviewView = require './atom-handson-sum-preview-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomHandsonSumPreview =
  atomHandsonSumPreviewView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomHandsonSumPreviewView = new AtomHandsonSumPreviewView(state.atomHandsonSumPreviewViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @atomHandsonSumPreviewView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-handson-sum-preview:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomHandsonSumPreviewView.destroy()

  serialize: ->
    atomHandsonSumPreviewViewState: @atomHandsonSumPreviewView.serialize()

  toggle: ->
    console.log 'AtomHandsonSumPreview was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
