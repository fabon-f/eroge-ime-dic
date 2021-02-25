# frozen_string_literal: true

require "nkf"

module ErogeImeDic::Util
  refine String do
    def to_katakana
      NKF.nkf("-w --katakana", self)
    end
    def to_hiragana
      NKF.nkf("-w --hiragana", self)
    end
  end
end
