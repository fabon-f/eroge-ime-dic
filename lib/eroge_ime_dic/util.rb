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

  def local_path(path)
    parent_directory = __dir__
    raise "__dir__ is nil" if parent_directory.nil?
    File.expand_path("../../#{path}", parent_directory)
  end
  module_function(:local_path)
end
