# frozen_string_literal: true

require "erogamescape"

module ErogeImeDic::ErogameScape
  class << self
    # block.call(nil, i) -> first SQL
    # block.call(last_row, i) -> next SQL
    def fetch_all_paginate(interval: 3, &block)
      # @type var last_row: nil|Hash
      # @type var result: Array[Hash[String,String]]
      last_row = nil
      result = []
      0.step do |i|
        # @type break: nil
        data = Erogamescape.query(yield last_row,i)
        break if data.size == 0
        last_row = data.last
        result.concat(data)
        sleep interval
      end
      result
    end

    def characters
      fetch_all_paginate(interval: 5) do |last_row|
        if last_row.nil?
          "SELECT id,name,furigana FROM characterlist ORDER BY id ASC LIMIT 8000"
        else
          "SELECT id,name,furigana FROM characterlist WHERE id > #{last_row["id"]} ORDER BY id ASC LIMIT 8000"
        end
      end
    end

    def brands
      Erogamescape.query("SELECT id,brandname AS name,brandfurigana AS furigana,kind FROM brandlist")
    end

    def musics
      fetch_all_paginate(interval: 5) do |last_row|
        if last_row.nil?
          "SELECT id,name,furigana FROM musiclist ORDER BY id ASC LIMIT 8000"
        else
          "SELECT id,name,furigana FROM musiclist WHERE id > #{last_row["id"]} ORDER BY id ASC LIMIT 8000"
        end
      end
    end

    def games
      expected_size = Erogamescape.query("SELECT COUNT(*) from gamelist").first&.fetch("count")&.to_i
      raise "ゲーム数の取得に失敗" if expected_size.nil?
      games = fetch_all_paginate(interval: 5) do |_, i|
        "SELECT id,gamename,furigana,brandname AS brand_id,median,okazu,axis_of_soft_or_hard FROM gamelist OFFSET #{i * 8000} LIMIT 8000"
      end
      game_size = games.map{|g| g["id"] }.uniq.size
      raise "ゲームの数(#{game_size})とCOUNTクエリの結果(#{expected_size})が一致していない" if game_size != expected_size
      games.sort_by{|g| g["id"].to_i }
    end

    def creators
      Erogamescape.query("SELECT createrlist.id,createrlist.name,createrlist.furigana,COUNT(*) FROM shokushu INNER JOIN createrlist on shokushu.creater = createrlist.id GROUP BY createrlist.id,createrlist.name,createrlist.furigana HAVING COUNT(*) >= 3 ORDER BY count DESC")
    end
  end
end
