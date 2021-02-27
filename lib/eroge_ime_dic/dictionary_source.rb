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
      brands.map{[_1["brandfurigana"].to_hiragana, _1["brandname"]]}
    end
  end
end
