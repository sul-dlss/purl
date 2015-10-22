class DocumentCacheResource
  def initialize(path)
    @path = path
  end

  def success?
    File.exist? @path
  end

  def body
    File.read(@path)
  end

  def updated_at
    File.mtime(@path)
  end
end
