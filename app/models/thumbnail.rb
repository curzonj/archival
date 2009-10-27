Thumbnail = Struct.new(:id, :source_prefix, :key, :url) do

  def has_source?
    !source.nil? && source.exists?
  end

  def source
    @source ||= AmazonHelper.list(source_prefix).first
  end

end
