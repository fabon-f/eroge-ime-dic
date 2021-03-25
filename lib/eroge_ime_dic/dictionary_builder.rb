# frozen_string_literal: true

require "nkf"

class ErogeImeDic::DictionaryBuilder
  # dataは[よみ(ひらがな), 単語, コメント(任意)]の配列
  attr_accessor :data, :header_comment
  def initialize(data: [], header_comment: "")
    @data = data
    @header_comment = header_comment

    @data, invalid_data =  @data.partition{|r| r[0].is_a?(String) && r[1].is_a?(String) }
    puts "Invalid data:\n#{invalid_data.map(&:inspect).join("\n")}\n" if invalid_data.size > 0

    sort!
  end

  def sort!
    hash = {}
    @data.each do |entry|
      hash[entry[0]] = [] unless hash.has_key?(entry[0])
      hash[entry[0]] << entry[1..2]
    end

    d = []
    hash.sort_by{|k,v| k}.each do |yomi, words|
      words.uniq.sort.each do |word|
        d.push([yomi, word[0], word[1]])
      end
    end
    @data = d
  end

  def generate_mozc(path)
    File.open(path, "w") do |f|
      f.puts(header_comment.gsub(/^/, "# ")) if header_comment != ""
      @data.each do |word|
        f.puts("#{word[0].gsub("う゛", "ゔ")}\t#{word[1]}\t固有名詞\t#{word[2] || "エロゲ"}")
      end
    end
  end

  def generate_atok(path)
    File.open(path, "w:UTF-16") do |f|
      f.puts("!!ATOK_TANGO_TEXT_HEADER_1")
      @data.each do |word|
        f.puts("#{word[0].gsub("う゛", "ゔ")}\t#{word[1]}\t固有一般")
      end
    end
  end

  def generate_msime(path)
    File.open(path, "wb:UTF-16LE") do |f|
      str = +""
      str << "!Microsoft IME Dictionary Tool\n"
      str << "!Format:WORDLIST\n"
      str << "\n"
      @data.each do |word|
        str << "#{word[0].gsub("う゛", "ゔ")}\t#{word[1]}\t固有名詞\t#{word[2] || "エロゲ"}\n"
      end
      f.write("\uFEFF" + NKF.nkf("-w -Lw", str))
    end
  end

  def generate_kotoeri(path)
    File.open(path, "w") do |f|
      f.puts <<-PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
PLIST

      @data.each do |word|
        f.puts("<dict><key>phrase</key><string>#{word[1].encode(xml: :text)}</string><key>shortcut</key><string>#{word[0].gsub("う゛", "ゔ").encode(xml: :text)}</string></dict>")
      end
      f.puts("</array>\n</plist>")
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
    else
      raise "非対応のエスケープ方式"
    end
  end

  def generate_skk(path)
    File.open(path, "w") do |f|
      f.puts(";;; -*- coding: utf-8 -*-")
      f.puts(header_comment.gsub(/^/, ";; ")) if header_comment != ""
      f.puts(";; okuri-ari entries.")
      f.puts(";; okuri-nasi entries.")

      hash = {}
      @data.each do |entry|
        hash[entry[0]] = [] unless hash.has_key?(entry[0])
        hash[entry[0]] << entry[1..2]
      end
      hash.sort_by{|k,v| k}.each do |entry|
        yomi = entry[0].gsub("ゔ", "う゛")
        entries = entry[1].map do |word|
          # wordは[単語,コメント]
          word[1].nil? ? escape_skk(word[0]) : "#{escape_skk(word[0])};#{escape_skk(word[1])}"
        end.uniq.join("/")
        f.puts("#{yomi} /#{entries}/")
      end
    end
  end
end
