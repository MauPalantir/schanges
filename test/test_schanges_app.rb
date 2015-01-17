gem "fakefs", :require => "fakefs/safe"
require 'fakefs/safe'

require 'test/unit'

class TestSoundChangeApp < MiniTest::Unit::TestCase
  # Test parsing parameters.
  def test_options_parse

    require_relative '../app/app'

    args = ["test.words"]
    assert_raises(RuntimeError) { SoundChanges::App.new args }

    FakeFS do
      FakeFS::FileSystem.add  "test.words", FakeFS::FakeFile.new
      FakeFS::FileSystem.add  "test2.words", FakeFS::FakeFile.new
      FakeFS::FileSystem.add  "test.sc", FakeFS::FakeFile.new



      # Assert
      args = ["test.words", "test2.words"]
      app = SoundChanges::App.new(args)
      assert_raises(RuntimeError) { app.send(:parse, args) }

      args = ["test.words", "test.sc"]
      app = SoundChanges::App.new(args)
      assert_equal [], app.send(:parse, args)
    end
  end
end
