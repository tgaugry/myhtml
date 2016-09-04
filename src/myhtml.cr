module Myhtml
  VERSION = "0.9"

  class Error < Exception
  end

  def self.lib_version
    v = Lib.version
    {v.major, v.minor, v.patch}
  end

  def self.version_string
    "#{VERSION} (libmyhtml #{lib_version.join('.')})"
  end
end

require "./myhtml/*"
