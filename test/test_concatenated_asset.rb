require "sprockets_test"

class ConcatenatedAssetTest < Sprockets::TestCase
  def setup
    @env = Sprockets::Environment.new
    @env.paths << fixture_path('asset')
  end

  test "requiring the same file multiple times has no effect" do
    assert_equal source_file("project.js").source, asset("multiple.js").to_s
  end

  test "requiring a file of a different format raises an exception" do
    assert_raise Sprockets::ContentTypeMismatch do
      asset("mismatch.js")
    end
  end

  test "dependencies appear in the source before files that required them" do
    assert_match(/Project.+Users.+focus/m, asset("application.js").to_s)
  end

  test "processing a source file with no engine extensions" do
    assert_equal source_file("users.js").source, asset("noengine.js").to_s
  end

  test "processing a source file with one engine extension" do
    assert_equal source_file("users.js").source, asset("oneengine.js").to_s
  end

  test "processing a source file with multiple engine extensions" do
    assert_equal source_file("users.js").source,
      asset("multipleengine.js").to_s
  end

  test "processing a source file in compat mode" do
    assert_equal source_file("project.js").source + source_file("users.js").source,
      asset("compat.js").to_s
  end

  test "included dependencies are inserted after the header of the dependent file" do
    assert_equal "# My Application\n" + source_file("project.js").source + "\nhello()\n",
      asset("included_header.js").to_s
  end

  test "requiring a file with a relative path" do
    assert_equal source_file("project.js").source,
      asset("relative/require.js").to_s
  end

  test "including a file with a relative path" do
    assert_equal "// Included relatively\n" + source_file("project.js").source + "\nhello()\n", asset("relative/include.js").to_s
  end

  test "can't require files outside the load path" do
    assert_raise Sprockets::FileNotFound do
      asset("relative/require_outside_path.js")
    end
  end

  test "__FILE__ is properly set in templates" do
    assert_equal %(var filename = "#{resolve("filename.js").path}";\n),
      asset("filename.js").to_s
  end

  test "asset mtime is the latest mtime of all processed sources" do
    mtime = Time.now
    path  = source_file("project.js").path
    File.utime(mtime, mtime, path)
    assert_equal File.mtime(path), asset("application.js").mtime
  end

  test "asset inherits the format extension and content type of the original file" do
    asset = asset("project.js")
    assert_equal ".js", asset.format_extension
    assert_equal "application/javascript", asset.content_type
  end

  test "asset is a rack response body" do
    body = ""
    asset("project.js").each { |part| body += part }
    assert_equal asset("project.js").to_s, body
  end

  test "asset length is source length" do
    assert_equal 46, asset("project.js").length
  end

  test "asset digest" do
    assert_equal "729a810640240adfd653c3d958890cfc4ec0ea84", asset("project.js").digest
  end

  test "asset is stale when one of its source files is modified" do
    asset = asset("application.js")
    assert !asset.stale?

    mtime = Time.now + 1
    File.utime(mtime, mtime, source_file("project.js").path)

    assert asset.stale?
  end

  def asset(logical_path)
    Sprockets::ConcatenatedAsset.new(@env, resolve(logical_path))
  end

  def resolve(logical_path)
    @env.resolve(logical_path)
  end

  def source_file(logical_path)
    Sprockets::SourceFile.new(resolve(logical_path))
  end
end
