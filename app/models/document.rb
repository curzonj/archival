class Document < ActiveRecord::Base

  serialize :cache, Hash

  def initialize(*args)
    super
    self.cache ||= {}
  end

  index do
    subject
    predicate
    notes
    tags
  end

  def public_url
    AmazonHelper.signed_fetch(key.name)
  end

  def key
    @aws_key ||= AmazonHelper.list("#{self.id}/original").first
  end

  def upload_path=(value)
    @upload_path = value
  end

  def request_processing!
    AmazonHelper.send_sqs 'process-document', :upload_path => @upload_path, :save_path => AmazonHelper.key("#{self.id}/")
  end

  def thumbnails(sized=nil)
    AmazonHelper.list("#{self.id}/thumbs/#{sized}").collect do |key|
      id = key.name[/\/([^\/]+)\.[^\/]+$/, 1]
      source = "#{self.id}/extracted/#{id}"
      Thumbnail.new(id, source, key.name, AmazonHelper.signed_fetch(key.name))
    end
  end

  def rebuild_sources
    puts "Looking at #{self.id}"
    list = thumbnails
    if list.size == 3 && !list.first.has_source?
      extracted = AmazonHelper.list("#{self.id}/extracted").first
      if extracted.nil?
        puts "#{self.id} is missing extracted images, but has thumbnails"
        return
      end
      source_key = extracted.name
      source_id = source_key[/\/([^\/]+)\.[^\/]+$/, 1]
      list.each do |item|
        src = RightAws::S3::Key.create(AmazonHelper.bucket, item.key)
        dest_key = item.key.gsub(/#{item.id}/, source_id)
        puts "Moving #{src.name} to #{dest_key}"
        src.move(dest_key)
      end
    end
  end
end
