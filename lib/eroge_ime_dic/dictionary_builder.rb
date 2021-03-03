# frozen_string_literal: true

class ErogeImeDic::DictionaryBuilder
  # dataは[よみ(ひらがな), 単語, コメント(任意)]の配列
  attr_accessor :data, :header_comment
  def initialize(data: [], header_comment: "")
    @data = data
    @header_comment = header_comment
  end

  def generate_mozc(io)
    io.puts(header_comment.gsub(/^/, "# ")) if header_comment != ""
    @data.map{|entry|entry.dup.tap{_1[0] = _1[0].gsub("う゛", "ゔ")}}.sort_by{_1[0]}.each do |entry|
      io.puts("#{entry[0]}\t#{entry[1]}\t固有名詞\t#{entry[2] || "エロゲ"}")
    end
  end

  private def escape_skk(str, escape: :concat)
    if escape == :concat
      escaped_str = str.gsub(/[\\\/;]/, { "\\" => "\\\\", "/" => "\\057", ";" => "\\073" })
      escaped_str == str ? str : "(concat \"#{escaped_str}\")"
    elsif escape == :omit
      # 単純にエントリを削除する
      str.match?(/[\/;]/) ? "" : str
    elsif escape == :zenkaku
      # 妥協して全角に置換する
      # バックスラッシュが含まれる場合セットで\ｼﾞｬｰﾝ/みたいな表現であることがほぼ100%確実なので、そちらも全角に置換する
      str.match?(/[\/;]/) ? str.gsub(/[\\\/;]/, { "\\" => "＼", "/" => "／", ";" => "；" }) : str
    end
  end

  def generate_skk(io)
    io.puts(";;; -*- coding: utf-8 -*-")
    io.puts(header_comment.gsub(/^/, ";; ")) if header_comment != ""
    io.puts(";; okuri-ari entries.")
    io.puts(";; okuri-nasi entries.")

    hash = {}
    @data.each do |entry|
      hash[entry[0]] = [] unless hash.has_key?(entry[0])
      hash[entry[0]] << entry[1..2]
    end
    hash.sort_by{_1}.each do |entry|
      yomi = entry[0].gsub("ゔ", "う゛")
      entries = entry[1].map{_1[1].nil? ? escape_skk(_1[0]) : "#{escape_skk(_1[0])};#{escape_skk(_1[1])}"}.uniq.join("/")
      io.puts("#{yomi} /#{entries}/")
    end
  end
end
