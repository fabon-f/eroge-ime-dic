# frozen_string_literal: true
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

    def characters
      characters = restore_cache(File.join(CACHE_DIRECTORY, "characters")) { ErogeImeDic::ErogameScape.characters }
      characters.map{[_1["furigana"].gsub(/\s+/, "").to_hiragana, _1["name"].gsub(/\s+/, "")]}
    end

    def brands
      brands = restore_cache(File.join(CACHE_DIRECTORY, "brands")) { ErogeImeDic::ErogameScape.brands }
        .sort_by{_1["id"].to_i}
      m = Modification.new(brands) {[_1["furigana"].to_hiragana, _1["name"]]}
      m.run do
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
      end.tap{STDERR.puts _1.select{|e|e[1].include?("(")}.map{|a|a.join(" ")}}
    end

    def musics
      musics = restore_cache(File.join(CACHE_DIRECTORY, "musics")) { ErogeImeDic::ErogameScape.musics }
      musics.map{[_1["furigana"].to_hiragana, _1["name"]]}
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
      match = lambda do |hash, conditions|
        conditions.any? do |cond|
          cond.all?{|k,v|hash[k.to_s]==v}
        end
      end
      splits, remaining = @original_data.partition{|data_row|match.(data_row, @splits)}
      splited = splits.map do |elem|
        entry = @transform.(elem)
        entry[1].split(/[()]/).reject(&:empty?).map{[entry[0],_1]}
      end.flatten(1)
      ign_pars, remaining = remaining.partition{|data_row|match.(data_row, @ignore_parenthesis)}
      ignored = ign_pars.map{|data_row|@transform.(data_row).tap{_1[1] = _1[1].gsub(/\(.+\)$/, "")}}
      remaining.reject{|data_row|match.(data_row, @deletions)}.map(&@transform) + @additions + splited + ignored
    end
  end
end
