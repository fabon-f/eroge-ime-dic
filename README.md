# eroge-ime-dic

エロゲーマーのための変換用IME辞書です。

元データにErogameScapeを利用しているため、網羅性が高いのが特徴です。また、手動でデータを追加する、タイトルを主タイトルと副タイトルに分割するなど様々な細かい配慮をしています。ただし、網羅性が高い反面、ノイズが若干見受けられます。

変換できる単語の例:

* 宿星(しゅくせい)のガールフレンド
* すきま桜(ざくら)とうその都会(まち)
* 月の虚(うろ) (「虚ノ少女」OP)
* 栖鴉(せいあ)の綿 (「未来ラジオと人工鳩」OP)
* 永久(とわ)より永遠(とわ)に (「少女神域∽少女天獄 -The Garden of Fifth Zoa-」ED)

全部インポートすると少し単語数が多いですが、必要なファイルだけインポートすることもできます。たとえば、「自分は抜きゲーのタイトルなんて入力しないよ」ということであれば非抜きゲーの辞書だけをインポートできます。

## ダウンロード

生成された辞書は[Googleドライブ](https://drive.google.com/drive/folders/168quurfp8LGiZXORQTkxhXEVARpYdr2J?usp=sharing)に置いてあります。自分が使っているIMEに応じて必要なファイルをダウンロードしてください。

### ファイル構成

* `eroge-dic`: 全部入り辞書
* `eroge-brand-dic`: ブランド名の辞書
* `eroge-chara-dic`: キャラ名の辞書
* `eroge-corp-game-dic`: 商業ゲームの名前の辞書
* `eroge-notnukige-dic`: 非抜きゲーの名前の辞書
* `eroge-game-dic`: エロゲの名前の辞書
* `eroge-music-dic`: エロゲソングの辞書

### Microsoft IME

`msime.zip`をダウンロードして解凍し、必要な辞書をインポートしてください。

### Google日本語入力・Mozc

`google_ime.zip`をダウンロードして解凍し、必要な辞書を辞書ツールでインポートしてください。

### ATOK

`atok.zip`をダウンロードして解凍し、必要な辞書をインポートしてください。
動作確認をしていないため、正しくインポートできないかもしれません。

### ことえり(Mac)

`kotoeri.zip`をダウンロードして解凍し、必要な`plist`ファイルを設定のユーザ辞書のところにドラッグ&ドロップしてください。数万の単語が追加される上に、元々の辞書と混ざってしまい、簡単には戻せないので、お気をつけて。

### SKK

`SKK-JISYO.eroge`をダウンロードし、適切な場所に配置し適切に設定してください。使っているSKK実装によってはUTF-8からEUC-JPに変換する必要があるかもしれません。

## ライセンス

生成用コード、辞書、ともにCC0(パブリックドメイン)です。利用・改造・再配布などは自己責任の範囲で全て自由です。

## ビルドに必要なもの

* MeCab
* mecab-ipadic-NEologd

## ビルド方法

1. `bundle install`
1. `bundle exec ./exe/make_dict`
