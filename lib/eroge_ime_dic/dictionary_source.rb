# frozen_string_literal: true

require "natto"

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

        nm.parse(parts[0]).to_s.split("\n").map(&:to_hiragana).uniq.each do |yomi_candidate|
          next unless yomi.start_with?(yomi_candidate)
          data.push([yomi_candidate, parts[0]])
          data.push([yomi.delete_prefix(yomi_candidate), parts[1]])
        end

        nm.parse(parts[1]).to_s.split("\n").map(&:to_hiragana).uniq.each do |yomi_candidate|
          next unless yomi.end_with?(yomi_candidate)
          data.push([yomi_candidate, parts[1]])
          data.push([yomi.delete_suffix(yomi_candidate), parts[0]])
        end
      end
      data.reject{ |r| r[0].empty? }
    end

    def characters
      characters = restore_cache(File.join(CACHE_DIRECTORY, "characters")) { ErogeImeDic::ErogameScape.characters }
      characters.map do |character|
        character_yomi = character["furigana"].gsub(/\s+/, "").to_hiragana
        character_name = character["name"].gsub(/\s+/, "")
        [character_yomi, character_name]
      end
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
      musics.map do |m|
        music_yomi = m["furigana"].to_hiragana
        [music_yomi, m["name"]]
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
        game_yomi = g["furigana"].to_hiragana.gsub(/\s+/, "")
        game_name = normalize_text(g["gamename"])
        [game_yomi, game_name]
      end
      game_entries + split_yomi(game_entries)
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
