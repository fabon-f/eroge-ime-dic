# eroge-ime-dic

エロゲーマーのための変換用IME辞書

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

## ビルドに必要なもの

* MeCab

## ビルド方法

1. `bundle install`
1. `bundle exec ./exe/make_dict`
