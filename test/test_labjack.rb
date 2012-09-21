require "test/unit"
require "labjack"

LIB="lib"
SRC="src"

class Test::LabjackRuby < Test::Unit::TestCase
  def test_sanity
    system("ruby -I#{LIB} #{LIB}/labjack.rb")
  end
end
