url = require 'url'
AtomHandsonSumPreviewView = require './atom-handson-sum-preview-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomHandsonSumPreview =
  subscriptions: null

  activate: (state) ->
    # atom-sum-preview:toggleイベントをsubscribe
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-handson-sum-preview:toggle': => @toggle()

    # カスタムオープナーを定義
    atom.workspace.addOpener (uriToOpen) ->
      console.log uriToOpen
      try
        {protocol, host, pathname} = url.parse(uriToOpen)
      catch error
        return
      return unless protocol is 'atom-handson-sum-preview:' # プロトコルがこのプラグインのプロトコルならビューを生成する

      try
        pathname = decodeURI(pathname) if pathname
      catch error
        return

      new AtomHandsonSumPreviewView editorId: pathname.substring(1)

  deactivate: ->
    @subscriptions.dispose()

  toggle: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    atom.workspace.open(@uriForEditor editor)

  # 新規メソッド
  uriForEditor: (editor) ->
    # プラグインのURI 例:atom-sum-preview://editor/1
    "atom-handson-sum-preview://editor/#{editor.id}"
