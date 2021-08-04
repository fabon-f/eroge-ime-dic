# frozen_string_literal: true

require "httpclient"
require "oga"

module ErogeImeDic::ErogameScape
  class << self
    def query(sql)
      endpoint = "https://erogamescape.dyndns.org/~ap2/ero/toukei_kaiseki/sql_for_erogamer_form.php"
      response_html = HTTPClient.new.post_content(endpoint, { "sql" => sql })
      document = Oga.parse_html(response_html)
      columns = document.css("#query_result_main th").map(&:text)
      document.css("#query_result_main tr").map do |row|
        row_data = row.css("td").map(&:text)
        row_data.size == 0 ? nil : columns.zip(row_data).to_h
      end.compact
    end

    # block.call(nil) -> first SQL
    # block.call(last_row) -> next SQL
    def fetch_all_paginate(interval: 3, &block)
      # @type var last_row: nil|Hash
      last_row = nil
      result = []
      0.step do |i|
        # @type break: nil
        data = query(yield last_row,i)
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
      query("SELECT id,brandname AS name,brandfurigana AS furigana,kind FROM brandlist")
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
      expected_size = query("SELECT COUNT(*) from gamelist").first["count"].to_i
      games = fetch_all_paginate(interval: 5) do |_, i|
        "SELECT id,gamename,furigana,brandname AS brand_id,median,okazu,axis_of_soft_or_hard FROM gamelist OFFSET #{i * 8000} LIMIT 8000"
      end
      game_size = games.map{|g| g["id"] }.uniq.size
      raise "ゲームの数(#{game_size})とCOUNTクエリの結果(#{expected_size})が一致していない" if game_size != expected_size
      games.sort_by{|g| g["id"].to_i }
    end

    def creators
      query("SELECT createrlist.id,createrlist.name,createrlist.furigana,COUNT(*) FROM shokushu INNER JOIN createrlist on shokushu.creater = createrlist.id GROUP BY createrlist.id,createrlist.name,createrlist.furigana HAVING COUNT(*) >= 3 ORDER BY count DESC")
    end
  end
end
