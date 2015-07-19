{View} = require 'space-pen'

module.exports =
  class AtomHandsonSumPreviewView extends View
    @content: ->
      @div class: 'atom-handson-sum-preview', =>
        @div outlet: "container"

    constructor: ({@editorId}) ->
      super
      @total = 0

      if @editorId?
        @resolveEditor(@editorId)

    # 新規メソッド エディターIDからエディタを取得し、取得できたらビューを描画する
    resolveEditor: (editorId) ->
      resolve = =>
        @editor = @getEditorById(editorId)

        if @editor?
          @renderSum()

      if atom.workspace?
        resolve() # atomが初期化済みならすぐ開く
      else
        @disposables.add atom.packages.onDidActivateInitialPackages(resolve) # atomが初期化されていないなら初期化後に開く

    # 新規メソッド エディタIDからエディタを取得する
    getEditorById: (editorId) ->
      for editor in atom.workspace.getTextEditors()
        return editor if editor.id?.toString() is editorId.toString()
      null

    # 新規メソッド 合計を計算し、ビューに描画する
    renderSum: ->
      text = @editor.getText() if @editor?
      @total = if text then @sumUp(text) else 0
      @renderContainer()

    # 新規メソッド 文字列を空白文字で分割し、数値に変換できたら合計する
    sumUp: (text) ->
    # 単純に空白文字で分割して合計する
      words = text.split(/\s+/)
      total = 0
      words.forEach (word) =>
        num = Number word
        total += num unless isNaN num
      total

    # 新規メソッド totalプロパティをビューに描画する
    renderContainer: ->
      @container.html "合計:#{@total}"

    getTitle: ->
      if @editor?
        "#{@editor.getTitle()} Sum Preview" # 元のタイトルを表示
      else
        "Sum Preview"

    getURI: ->
      "atom-handson-sum-preview://editor/#{@editorId}" if @editorId?