{View} = require 'space-pen'
{CompositeDisposable} = require 'atom'

module.exports =
  class AtomHandsonSumPreviewView extends View
    atom.deserializers.add(this)

    @deserialize: (state) ->
      new AtomHandsonSumPreviewView(state)

    @content: ->
      @div class: 'atom-handson-sum-preview', =>
        @div outlet: "container"

    constructor: ({@editorId}) ->
      super
      @disposables = new CompositeDisposable
      @total = 0

      if @editorId?
        @resolveEditor(@editorId)

    serialize: ->
      deserializer: 'AtomHandsonSumPreviewView'
      editorId: @editorId

    # 新規メソッド イベント関連のオブジェクトを破棄
    destroy: ->
      @disposables.dispose()

    # エディターIDからエディタを取得し、取得できたらビューを描画する
    resolveEditor: (editorId) ->
      resolve = =>
        @editor = @getEditorById(editorId)

        if @editor?
          @handleEvents()
          @renderSum()

      if atom.workspace?
        resolve() # atomが初期化済みならすぐ開く
      else
        @disposables.add atom.packages.onDidActivateInitialPackages(resolve) # atomが初期化されていないなら初期化後に開く

    # 新規メソッド イベント関連の初期化
    handleEvents: ->
      if @editor?
        # 元のファイルが更新されたら合計を再計算
        @disposables.add @editor.onDidStopChanging => @renderSum()

    # エディタIDからエディタを取得する
    getEditorById: (editorId) ->
      for editor in atom.workspace.getTextEditors()
        return editor if editor.id?.toString() is editorId.toString()
      null

    # 合計を計算し、ビューに描画する
    renderSum: ->
      text = @editor.getText() if @editor?
      @total = if text then @sumUp(text) else 0
      @renderContainer()

    # 文字列を空白文字で分割し、数値に変換できたら合計する
    sumUp: (text) ->
    # 単純に空白文字で分割して合計する
      words = text.split(/\s+/)
      total = 0
      words.forEach (word) =>
        num = Number word
        total += num unless isNaN num
      total

    # totalプロパティをビューに描画する
    renderContainer: ->
      @container.html "合計:#{@total}"

    getTitle: ->
      if @editor?
        "#{@editor.getTitle()} Sum Preview" # 元のタイトルを表示
      else
        "Sum Preview"

    getURI: ->
      "atom-handson-sum-preview://editor/#{@editorId}" if @editorId?