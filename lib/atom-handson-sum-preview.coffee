url = require 'url'
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

    # カスタムオープナーを定義
    atom.workspace.addOpener (uriToOpen) ->
      try
        {protocol, host, pathname} = url.parse(uriToOpen)
      catch error
        return
      return unless protocol is 'atom-handson-sum-preview:' # プロトコルがこのプラグインのプロトコルならビューを生成する

      try
        pathname = decodeURI(pathname) if pathname
      catch error
        return

      {TextEditor} = require 'atom'
      view = new TextEditor
      view.setText "editorId: #{pathname.substring(1)}"
      view

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomHandsonSumPreviewView.destroy()

  serialize: ->
    atomHandsonSumPreviewViewState: @atomHandsonSumPreviewView.serialize()

  toggle: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    atom.workspace.open(@uriForEditor editor)

  # 新規メソッド
  uriForEditor: (editor) ->
    # プラグインのURI 例:atom-sum-preview://editor/1
    "atom-handson-sum-preview://editor/#{editor.id}"
