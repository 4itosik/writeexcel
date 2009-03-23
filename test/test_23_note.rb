##########################################################################
# test_23_note.rb
#
# Tests for some of the internal method used to write the NOTE record that
# is used in cell comments.
#
# reverse('©'), September 2005, John McNamara, jmcnamara@cpan.org
#
# original written in Perl by John McNamara
# converted to Ruby by Hideo Nakamura, cxn03651@msj.biglobe.ne.jp
#
#########################################################################
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"

require "test/unit"
require 'writeexcel'

class TC_note < Test::Unit::TestCase

  def setup
    t = Time.now.strftime("%Y%m%d")
    path = "temp#{t}-#{$$}-#{rand(0x100000000).to_s(36)}"
    @test_file           = File.join(Dir.tmpdir, path)
    @workbook   = Spreadsheet::WriteExcel.new(@test_file)
    @worksheet  = @workbook.add_worksheet
  end

  def teardown
    @workbook.close
    File.unlink(@test_file) if FileTest.exist?(@test_file)
  end

  def test_blank_author_name
    data = @worksheet.comment_params(2,0,'Test')
    row      = data[0]
    col      = data[1]
    author   = data[4]
    encoding = data[5]
    visible  = data[6]
    obj_id   = 1
    
    caption = sprintf(" \tstore_note")
    target  = %w(
        1C 00 0C 00 02 00 00 00 00 00 01 00 00 00 00 00
    ).join(' ')
    result = unpack_record(
        @worksheet.store_note(row,col,obj_id,author,encoding,visible))
    assert_equal(target, result, caption)
  end

  def test_defined_author_name
    data = @worksheet.comment_params(2,0,'Test', :author => 'Username')
    row      = data[0]
    col      = data[1]
    author   = data[4]
    encoding = data[5]
    visible  = data[6]
    obj_id   = 1
    
    caption = sprintf(" \tstore_note")
    target  = %w(
        1C 00 14 00 02 00 00 00 00 00 01 00 08 00 00 55
        73 65 72 6E 61 6D 65 00
    ).join(' ')
    result = unpack_record(
        @worksheet.store_note(row,col,obj_id,author,encoding,visible))
    assert_equal(target, result, caption)
  end

  ###############################################################################
  #
  # Unpack the binary data into a format suitable for printing in tests.
  #
  def unpack_record(data)
    data.unpack('C*').map! {|c| sprintf("%02X", c) }.join(' ')
  end

end
