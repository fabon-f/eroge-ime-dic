# frozen_string_literal: true

require "natto"
require "yaml"

module ErogeImeDic::DictionarySource
  CACHE_DIRECTORY = File.expand_path("../../cache", __dir__)
  class << self
    using ErogeImeDic::Util
    def restore_cache(path, &block)
      File.open(path) do |f|
        return Marshal.restore(f)
      end
    rescue Errno::ENOENT
      obj = yield
      File.open(path, "w") do |f|
        Marshal.dump(obj, f)
      end
      obj
    end

    def normalize_text(text)
      text.gsub(/[[:blank:]]+/, " ")
    end

    def normalize_yomi(text)
      text.gsub(/[[:blank:]・、。!?！？「」『』×<>〜～-]+/, "")
    end

    def neologd_path
      nm = Natto::MeCab.new
      neologd_filepath = nm.dicts.map(&:filepath).detect{|p| p.include?("mecab-ipadic-neologd")}
      File.dirname(neologd_filepath)
    end

    def split_yomi(entries)
      data = []
      space_regex = /\s+(?=[^A-Za-z0-9&])|(?<=[^A-Za-z0-9&])\s+/
      nm = Natto::MeCab.new(nbest: 5, output_format_type: "yomi", dicdir: neologd_path)

      entries.filter{|e| e[1].match?(space_regex) }.each do |e|
        yomi = e[0]
        parts = e[1].split(space_regex).map{|s| s.gsub(/^[-－–—〜～]|[-－–—〜～]$/, "") }.reject(&:empty?)
        next unless parts.size == 2

        nm.parse(parts[0]).to_s.split("\n").map{|y| y.to_hiragana.gsub(/[^\p{Hiragana}ー゛a-zA-Z]/, "") }.uniq.each do |yomi_candidate|
          next unless yomi.start_with?(yomi_candidate)
          data.push([yomi_candidate, parts[0]])
          data.push([yomi.delete_prefix(yomi_candidate), parts[1]])
        end

        nm.parse(parts[1]).to_s.split("\n").map{|y| y.to_hiragana.gsub(/[^\p{Hiragana}ー゛]/, "") }.uniq.each do |yomi_candidate|
          next unless yomi.end_with?(yomi_candidate)
          data.push([yomi_candidate, parts[1]])
          data.push([yomi.delete_suffix(yomi_candidate), parts[0]])
        end
      end
      data.reject{ |r| r[0].empty? }
    end

    def characters
      characters = restore_cache(File.join(CACHE_DIRECTORY, "characters")) { ErogeImeDic::ErogameScape.characters }
      character_data = characters.map do |character|
        character_yomi = normalize_yomi(character["furigana"].gsub(/[[:blank:]]+/, "").to_hiragana)
        character_name = character["name"].gsub(/[[:blank:]]+/, "")
        [character_yomi, character_name]
      end

      YAML.load_file(File.expand_path("../../data/eroge-character-extra.yml", __dir__)).each do |brand, games|
        games.each do |game, characters|
          characters.each { |character| character_data << character.map{|t| t.gsub(/[[:blank:]]+/, "") } }
        end
      end

      character_data
    end

    def brands
      brands = restore_cache(File.join(CACHE_DIRECTORY, "brands")) { ErogeImeDic::ErogameScape.brands }
        .filter{|b| b["kind"] == "CORPORATION" }
        .sort_by{|b| b["id"].to_i}
      m = Modification.new(brands) do |b|
        brand_yomi = b["furigana"].to_hiragana
        [brand_yomi, b["name"]]
      end
      m.run do
        # @type self: Modification
        spl 1,"âge(age)"
        ign 46, "ILLUSION(Dreams)"
        spl 99, "Kur-Mar-Ter(クルマレテル)"
        ign 163, "SPLASH(DOTMAN系列)"
        add "けろきゅー", "ケロQ"
        spl 190, "D.O.(ディーオー)"
        del 244, "ひよこソフト(有限会社エーエムシー)"
        add "ひよこそふと", "ひよこソフト"
        ign 284, "maika(J-BOX)"
        spl 298, "May-Be SOFT(メイビーソフト)"
        del 307, "Liar-soft(ビジネスパートナー)"
        add "らいあーそふと", "Liar-soft"
        add "らいあーそふと", "ライアーソフト"
        spl 325, "rúf(ruf)"
        spl 433, "AyPio(アーヴォリオ)"
        ign 509, "HOOKSOFT(HOOK)"
        spl 513, "黒†救(クロス)"
        spl 537, "公爵(デューク)"
        ign 622, "GungHo Works(Interchannel、NECインターチャネル)"
        del 628, "SEGA(セガゲームス)"
        del 685, "マイナビ出版(毎日コミュニケーションズ)"
        spl 688, "Carrière(Carriere)"
        spl 719, "郎猫儿(ランマール)"
        del 728, "SIEJA(SCEI)"
        del 770, "小学館集英社プロダクション(小学館プロダクション)"
        spl 772, "コーエー(光栄)"
        del 775, "ジェネオンエンタテイメント(パイオニアLDC)"
        ign 830, "黒蝶(DOTMAN系列)"
        spl 903, "NIGRED(ニグレド)"
        del 966, "マーベラス(マーベラスエンターテイメント、マーベラスAQL)"
        spl 1020, "るチャ!(LUCHA!)"
        spl 1194, "CandySoft(きゃんでぃそふと)"
        ign 1217, "burston(エロゲーメーカー)"
        ign 1246, "DreamSoft(F&C FC03)"
        ign 1305, "ハーベスト(ビジュアルアーツ)"
        spl 1326, "M-pure(MAIKA-P)"
        del 1352, "システムソフト・ベータ(SystemSoft Alpha)"
        add "しすてむそふとべーた", "システムソフト・ベータ"
        ign 1417, "SPLUSH(すぺじゃに系列)"
        del 1418, "ぱれっと(CD-BROS)"
        del 1453, "Cybele(黒姫)"
        add "きゅべれ", "Cybele"
        add "くろひめ", "黒姫"
        ign 1721, "May-Be Soft(有限会社リエーブル)"
        del 1791, "A.S.S(Abnormal Software Studio)"
        add "あぶのーまるそふとうぇあすたじお", "Abnormal Software Studio"
        ign 1936, "TJR(THE JOLLY ROGER)"
        add "ざじょりーろじゃー", "THE JOLLY ROGER"
        del 2025, "ensky(天田印刷加工)"
        del 2058, "DualTail(DualMage)"
        add "でゅあるめいじ", "DualMage"
        add "でゅあるている", "DualTail"
        add "でゅあるている", "dualtail"
        del 2119, "ZERO(奇怪な世界)"
        del 2129, "ノアールソフト(NOIR)"
        add "のあーるそふと", "Noirsoft"
        add "のあーるそふと", "ノアールソフト"
        add "のあーる", "NOIR"
        del 2166, "ビクターエンタテインメント(ビクター音楽産業)"
        del 2217, "ぷちけろ(プチケロQ)"
        add "ぷちけろ", "ぷちけろ"
        add "ぷちけろきゅう", "プチケロQ"
        add "ぷちけろきゅー", "プチケロQ"
        del 2224, "バンダイナムコエンターテインメント(バンダイナムコゲームス)"
        del 2345, "ひよこソフト(2008年～)(株式会社トゥインクルクリエイト)"
        add "ひよこそふと", "ひよこソフト"
        del 2394, "EXNOA(DMM GAMES)"
        add "えくすのあ", "EXNOA"
        add "れいるそふと", "レイルソフト"
        spl 2628, "澪(MIO)"
        del 2780, "hibiki works(暁WORKS響SIDE)"
        add "ひびきわーくす", "hibiki works"
        add "あかつきわーくすひびきさいど", "暁WORKS響SIDE"
        spl 2900, "Yatagarasu(八咫鴉)"
        spl 3327, "ああとあいてぃ(AATIT)"
        ign 3632, "Xyz(有限会社スケアクロウ)"
        del 3797, "BlusterD(B-luster)"
        add "ぶらすたーでぃー", "BlusterD"
        add "びーらすたー", "B-luster"
        spl 3997, "GLacé(GLace)"
        del 4158, "side-B(2014年-)"
        add "さいどびー", "side-B"
        del 4689, "Anim M&W(Anim Mother&Wife)"
        add "あにむまざーあんどわいふ", "ANIM Mother&Wife"
        spl 5809, "CFK(シーエフケー)"
        ign 5825, "Dreams (ILLUSION)"
      end.tap{|brands| STDERR.puts brands.select{|e|e[1].include?("(")}.map{|a|a.join(" ")}}
    end

    def musics
      musics = restore_cache(File.join(CACHE_DIRECTORY, "musics")) { ErogeImeDic::ErogameScape.musics }
      m = Modification.new(musics) do |m|
        music_yomi = normalize_yomi(m["furigana"].to_hiragana)
        [music_yomi, m["name"]]
      end
      m.run do
        # @type self: Modification
        del 3905, "ぶるま～ず☆"
        add "ぶるまーず", "ぶるま～ず☆"
        del 3921, "ぶるま～ずへようこそ☆"
        add "ぶるまーずへようこそ", "ぶるま～ずへようこそ☆"
      end
    end

    def games(include_nuki: true, include_doujin: true)
      brands = restore_cache(File.join(CACHE_DIRECTORY, "brands")) { ErogeImeDic::ErogameScape.brands }
        .reduce({}) {|h,g| h[g["id"]] = g; h }
      games = restore_cache(File.join(CACHE_DIRECTORY, "games")) { ErogeImeDic::ErogameScape.games }
        .filter{|game| include_nuki || game["okazu"] == "f" }
        .filter do |game|
          brand = brands[game["brand_id"]]
          is_doujin = brand != nil ? brand["kind"] == "CIRCLE" : true
          include_doujin || !is_doujin
        end
      game_entries = games.map do |g|
        game_yomi = normalize_yomi(g["furigana"].to_hiragana)
        game_name = normalize_text(g["gamename"])
        [game_yomi, game_name]
      end
      game_entries + split_yomi(game_entries)
    end

    def creators
      creators = restore_cache(File.join(CACHE_DIRECTORY, "creators")) { ErogeImeDic::ErogameScape.creators }
      m = Modification.new(creators) do |c|
        creator_yomi = normalize_yomi(c["furigana"].to_hiragana)
        [creator_yomi, c["name"]]
      end
      creator_entries = m.run do
        # @type self: Modification
        spl 6003, "ヒマリ(陽茉莉)"
        ign 13068, "KIZAWA studio(株式会社KIZAWA studio)"
        del 3360, "榊原ゆい(雛野まよ、Hinano、まりあ)"
        addl %w(さかきばらゆい 榊原ゆい ひなのまよ 雛野まよ ひなの Hinano まりあ まりあ)
        del 5739, "成瀬未亜(平山紗弥、笠原晴香、加賀美琴音、井上ねねこ、日比谷小桃、佐倉千枝理、酉井凛々子、松永亜夜)"
        addl %w(なるせみあ 成瀬未亜 ひらやまさや 平山紗弥 かさはらはるか 笠原晴香 かがみことね 加賀美琴音 いのうえねねこ 井上ねねこ ひびやこもも 日比谷小桃 さくらちえり 佐倉千枝理 とりいりりこ 酉井凛々子 まつながあや 松永亜夜)
        ign 5973, "民安ともえ(たみやすともえ、たみー)"
        addl %w(たみやすともえ たみやすともえ たみー たみー)
        del 5980, "春日アン(春乃うらら)"
        addl %w(かすがあん 春日アン はるのうらら 春乃うらら)
        spl 5819, "Rita(理多)"
        del 12200, "英みらい(大山チロル、ひつじまる)"
        addl %w(はなふさみらい 英みらい おおやまちろる 大山チロル ひつじまる ひつじまる)
        del 5818, "七ヶ瀬輪(深井晴花)"
        addl %w(なながせりん 七ヶ瀬輪 ふかいはるか 深井晴花)
        del 13369, "大高あまね(椎那天、柊真冬、秋山はるる)"
        addl %w(おおだかあまね 大高あまね しいなあまね 椎那天 ひいらぎまふゆ 柊真冬 あきやまはるる 秋山はるる)
        del 5785, "カンザキカナリ(三日月一花)"
        addl %w(かんざきかなり カンザキカナリ みかづきいちか 三日月一花)
        spl 6862, "一条和矢(一条和也)"
        spl 5804, "野神奈々(野上奈々)"
        del 15195, "今谷皆美(桃也みなみ)"
        addl %w(いまやみなみ 今谷皆美 ももやみなみ 桃也みなみ)
        del 11175, "涼貴涼(笑兵衛)"
        addl %w(すずきりょう 涼貴涼 しょうべえ 笑兵衛)
        del 6006, "水純なな歩(中家菜穂)"
        addl %w(みすみななほ 水純なな歩 なかやなほ 中家菜穂)
        del 18316, "あかしゆき(赤司弓妃、サトウユキ)"
        addl %w(あかしゆき あかしゆき あかしゆき 赤司弓妃 さとうゆき サトウユキ)
        spl 1070, "与猶啓至(ヨナオケイシ)"
        del 6048, "かずなさやか(計名さや香)"
        addl %w(かずなさやか かずなさやか かずなさやか 計名さや香)
        del 5962, "なかせひな(中瀬ひな、村上仁美)"
        addl %w(なかせひな なかせひな なかせひな 中瀬ひな むらかみひとみ 村上仁美)
        spl 12198, "ひむろゆり(氷室百合)"
        del 14557, "犬飼あお(夕凪音)"
        addl %w(いぬかいあお 犬飼あお ゆうなぎおと 夕凪音)
        del 7511, "琴音有波(紅月ことね)"
        addl %w(ことねあるは 琴音有波 あかつきことね 紅月ことね)
        del 15613, "ロックンバナナ(有限会社ロックンバナナ)"
        add "ろっくんばなな", "ロックンバナナ"
        spl 12359, "真理絵(marie)"
        del 15570, "彩瀬ゆり(分倍河原シホ)"
        addl %w(あやせゆり 彩瀬ゆり ぶばいがわらしほ 分倍河原シホ)
        del 12859, "RMG(Rainbow-Motion-Graphics)"
        addl %w(あーるえむじー RMG れいんぼーもーしょんぐらふぃっく Rainbow-Motion-Graphics)
        del 5978, "岩泉まい(樋口まゆら、樋口まゆ)"
        addl %w(いわいずみまい 岩泉まい ひぐちまゆら 樋口まゆら ひぐちまゆ 樋口まゆ)
        del 6103, "櫻井ありす(水邑琴音、綾瀬とまり)"
        addl %w(さくらいありす 櫻井ありす みずむらことね 水邑琴音 あやせとまり 綾瀬とまり)
        del 18658, "WAMSOFT(合資会社ワムソフト)"
        add "わむそふと", "WAMSOFT"
        ign 3032, "阿保剛(Takeshi Abo)"
        del 2808, "水月陵(KIYO)"
        addl %w(みずつきりょう 水月陵 きよ KIYO)
        del 6055, "まりなりな(大野まりな)"
        addl %w(まりなりな まりなりな おおのまりな 大野まりな)
        del 2551, "MANYO(まにょっ、Little Wing、六浦館)"
        addl %w(まにょっ MANYO まにょっ まにょっ りとるうぃんぐ Little\ Wing むつうらたて 六浦館)
        del 9218, "藤乃理香(藤咲ちま)"
        addl %w(ふじのりか 藤乃理香 ふじさきちま 藤咲ちま)
        spl 168, "山本和枝(やまもと☆かずえ)"
        del 784, "朝凪軽(GM、夕凪)"
        addl %w(あさなぎけい 朝凪軽 じーえむ GM ゆうなぎ 夕凪)
        spl 15302, "くすはらゆい(楠原ゆい)"
        spl 5208, "遊真一希(遊馬一希)"
        del 5943, "神村ひな(MIKAKO)"
        addl %w(かみむらひな 神村ひな みかこ MIKAKO)
        del 3024, "松本慎一郎(M.U.T.S.MusicStudio、マッツミュージックスタジオ)"
        addl %w(まつもとしんいちろう 松本慎一郎 まっつみゅーじっくすたじお M.U.T.S.MusicStudio まっつみゅーじっくすたじお マッツミュージックスタジオ)
        spl 7648, "岸尾だいすけ(岸尾大輔)"
        del 502, "さっぽろももこ(RIKA)"
        addl %w(さっぽろももこ さっぽろももこ りか RIKA)
        spl 4525, "佐藤ひろ美(佐藤裕美)"
        del 5840, "田中美智(多田美智)"
        addl %w(たなかみち 田中美智 ただみとも 多田美智)
        del 6432, "一比未子(比未子)"
        addl %w(もとひみこ 一比未子 ひみこ 比未子)
        spl 1984, "AG-promotion(AGプロモーション)"
        del 6002, "渡会ななせ(橘りん、森永ゆう、春日咲、立花みかみ)"
        addl %w(わたらいななせ 渡会ななせ たちばなりん 橘りん もりながゆう 森永ゆう かすがさき 春日咲 たちばなみかみ 立花みかみ)
        del 2489, "木緒なち(グッチー)"
        addl %w(きおなち 木緒なち ぐっちー グッチー)
        ign 6702, "美月(声優)"
        del 16553, "BraveHearts(株式会社ブレイブハーツ)"
        addl %w(ぶれいぶはーつ BraveHearts ぶれいぶはーつ ブレイブハーツ)
        del 3536, "NSN(西野尚利)"
        addl %w(えぬえすえぬ NSN にしのなおとし 西野尚利)
        spl 14592, "yo-yu(よゆ)"
        spl 6760, "空乃太陽(空野太陽)"
        del 1929, "assault(あさのじ)"
        addl %w(あさると assault あさのじ あさのじ)
        del 2882, "Dreaming Rabbit(MASA)"
        addl %w(どりーみんぐらびっと Dreaming\ Rabbit まさ MASA)
        del 58, "長岡建蔵(美駒)"
        addl %w(ながおかけんぞう 長岡建蔵 みく 美駒)
        del 2298, "桃井はるこ(UNDER17)"
        addl %w(ももいはるこ 桃井はるこ あんだーせぶんてぃーん UNDER17)
        del 16657, "彩雅介(きまぐれアフター、T.O.P.)"
        addl %w(さいがかい 彩雅介 きまぐれあふたー きまぐれアフター てぃーおーぴー T.O.P.)
        ign 5941, "AYA(声優)"
        del 1811, "桜ロマ子(桜島サロマ子)"
        addl %w(さくらろまこ 桜ロマ子 さくらじまさろまこ 桜島サロマ子)
        del 5986, "しまだかおり(かおりん)"
        addl %w(しまだかおり しまだかおり かおりん かおりん)
        del 622, "鏡裕之(和泉時彦)"
        addl %w(かがみひろゆき 鏡裕之 いずみときひこ 和泉時彦)
        del 1230, "渡辺明夫(ぽよよんろっく、桜桃ひな)"
        addl %w(わたなべあきお 渡辺明夫 ぽよよんろっく ぽよよんろっく さくらももひな 桜桃ひな)
        del 2151, "七央結日(安堂こたつ)"
        addl %w(ななおゆひ 七央結日 あんどうこたつ 安堂こたつ)
        del 14550, "霧島はるな(水無月じゅん)"
        addl %w(きりしまはるな 霧島はるな みなづきじゅん 水無月じゅん)
        spl 7626, "中澤歩(中澤アユム)"
        del 939, "折戸伸治(がんま)"
        addl %w(おりとしんじ 折戸伸治 がんま がんま)
        spl 4994, "YURIA(有里亜)"
        spl 2410, "玉沢円(ふじまる)"
        addl %w(たまさわつぶら 玉沢円 ふじまる ふじまる)
        spl 142, "相川亜利砂(あいかわ亜利砂)"
        spl 6690, "leimonZ(礼門Z)"
        del 2546, "リバーサイド・ミュージック(feel、Cats、キャッツ)"
        addl %w(りばーさいどみゅーじっく リバーサイド・ミュージック ふぃーる feel きゃっつ Cats きゃっつ キャッツ)
        ign 10549, "このは(声優)"
        del 17833, "株式会社キューン・プラント(quunplant)"
        addl %w(きゅーんぷらんと キューン・プラント きゅーんぷらんと quunplant)
        del 892, "田中ロミオ(山田一)"
        addl %w(たなかろみお 田中ロミオ やまだはじめ 山田一)
        del 21810, "宇佐美日和(玉置ひよ)"
        addl %w(うさみひより 宇佐美日和 たまきひよ 玉置ひよ)
        del 138, "菅野ひろゆき(菅野洋之、妃路雪≠卿、剣乃ゆきひろ)"
        addl %w(かんのひろゆき 菅野ひろゆき かんのひろゆき 菅野洋之 ひろゆききょう 妃路雪≠卿 けんのゆきひろ 剣乃ゆきひろ)
        del 19735, "Ayumi.(オリヒメヨゾラ、織姫よぞら、nerine)"
        addl %w(あゆみ Ayumi. おりひめよぞら オリヒメヨゾラ おりひめよぞら 織姫よぞら ねりね nerine)
        del 1238, "吉田誠治(棚葉)"
        addl %w(よしだせいじ 吉田誠治 たなは 棚葉)
        del 14558, "本多未季(本多しの舞、おおたけしのぶ)"
        addl %w(ほんだみき 本多未季 ほんだしのぶ 本多しの舞 おおたけしのぶ おおたけしのぶ)
        spl 17287, "与呼太(yokota)"
        del 7436, "Riryka(みるくくるみ)"
        addl %w(りりか Riryka みるくくるみ みるくくるみ)
      end
      ignored, rest = creator_entries.partition{|c| c[1].include?("(") }
      STDERR.puts ignored.map{|e| [creators.find{|c| c["name"] == e[1] && c["furigana"] == e[0].to_katakana }["id"], *e].inspect }.take(200)
      rest
    end
  end

  class Modification
    def initialize(original_data, &transform)
      @deletions = []
      @additions = []
      @splits = []
      @ignore_parenthesis = []
      @original_data = original_data
      @transform = transform
    end
    def add(furigana, name)
      @additions.push([furigana, name])
    end
    def addl(arr)
      @additions.concat(arr.each_slice(2).to_a)
    end
    def del(id = nil, name = nil, **conditions)
      conditions[:id] = id.to_s if conditions[:id] == nil && id != nil
      conditions[:name] = name if conditions[:name] == nil && name != nil
      @deletions.push(conditions)
    end
    def spl(id = nil, name = nil, **conditions)
      conditions[:id] = id.to_s if conditions[:id] == nil && id != nil
      conditions[:name] = name if conditions[:name] == nil && name != nil
      @splits.push(conditions)
    end
    def ign(id = nil, name = nil, **conditions)
      conditions[:id] = id.to_s if conditions[:id] == nil && id != nil
      conditions[:name] = name if conditions[:name] == nil && name != nil
      @ignore_parenthesis.push(conditions)
    end
    def run(&block)
      instance_eval(&block)
      # @type var match: ^(Hash, Array[Hash]) -> bool
      match = lambda do |hash, conditions|
        conditions.any? do |cond|
          cond.all?{|k,v|hash[k.to_s]==v}
        end
      end
      splits, remaining = @original_data.partition{|data_row|match.(data_row, @splits)}
      splited = splits.map do |elem|
        entry = @transform.(elem)
        entry[1].split(/[()]/).reject(&:empty?).map{ |e| [entry[0], e] }
      end.flatten(1)
      ign_pars, remaining = remaining.partition{|data_row|match.(data_row, @ignore_parenthesis)}
      ignored = ign_pars.map do |data_row|
        @transform.(data_row).tap{ |r| r[1] = r[1].gsub(/\(.+\)$/, "")}
      end
      remaining.reject{|data_row|match.(data_row, @deletions)}.map(&@transform) + @additions + splited + ignored
    end
  end
end
