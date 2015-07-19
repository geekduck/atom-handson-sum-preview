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
    # プレビュー画面がアクティブ状態でtoggleされたら閉じる
    if atom.workspace.getActivePaneItem() instanceof AtomHandsonSumPreviewView
      atom.workspace.destroyActivePaneItem()
      return

    editor = atom.workspace.getActiveTextEditor()
    return unless editor?
    # editorに対応するプレビュー画面がすでに開かれていれば閉じ、そうでなければ開く
    @addPreviewForEditor(editor) unless @removePreviewForEditor(editor)

  # 新規メソッド
  uriForEditor: (editor) ->
    # プラグインのURI 例:atom-handson-sum-preview://editor/1
    "atom-handson-sum-preview://editor/#{editor.id}"

  removePreviewForEditor: (editor) ->
    uri = @uriForEditor(editor)
    # 開こうとしているURIですでに開かれてるビューがあれば閉じる
    previewPane = atom.workspace.paneForURI(uri)
    if previewPane?
      previewPane.destroyItem(previewPane.itemForURI(uri))
      true
    else
      false

  addPreviewForEditor: (editor) ->
    # URIを生成してopen
    uri = @uriForEditor(editor)
    previousActivePane = atom.workspace.getActivePane() # プレビュー元となるテキストエディタ
    options =
      split: 'right' # 画面を分割して右側に表示する
      searchAllPanes: true
    atom.workspace.open(uri, options).done (atomHandsonSumPreviewView) ->
      if atomHandsonSumPreviewView instanceof AtomHandsonSumPreviewView
        previousActivePane.activate() # プレビュー画面をアクティブにすると使いにくいので元のpaneをアクティブにする
