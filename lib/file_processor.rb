$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << 'vendor/plugins/makes_sense/lib'

require 'sqs_processor'
require 'amazon_helper'
require 'uploaded_file'
require 'RMagick'

class FileProcessor < SqsProcessor
  THUMBNAIL_SIZES = [ 100, 200, 600 ]

  subscribes_to 'process-document'

  def on_message(json)
    key = move_upload(json['upload_path'], json['save_path'])
    return if key.nil?

    download(key.name) do |path, dir|
      file = UploadedFile.new(path)
      file.pdf_images.each_with_index do |image, index|
        key = json['save_path'] + "extracted/#{index}/#{File.basename(image)}"
        AmazonHelper.upload(key, image)
        upload_thumbnails(image, index, json['save_path'])
      end
    end
  end

  def upload_thumbnails(image, index, save_path)
    THUMBNAIL_SIZES.each do |size|
      path = File.dirname(image) + "thumbnail-#{index}-#{size}.jpg"
      create_thumbnail(image, size, path)
      AmazonHelper.upload(save_path + "thumbs/#{size}/#{index}.jpg",
                          path, 'content-type' => 'image/jpeg')
    end
  end

  def move_upload(upload_path, save_path)
    key = AmazonHelper.list(upload_path).first
    if key.nil?
      logger.error("Failed to find any files in #{json['upload_path']}")
      return
    end

    filename = File.basename(key.name)
    new_key = save_path + "original/#{filename}"
    key.move(new_key)
    AmazonHelper.bucket.key(new_key)
  end

  def download(file)
    workdir = `mktemp -d`.strip
    path, headers = AmazonHelper.download(file, workdir)

    yield path, workdir
  ensure
    FileUtils.rm_rf workdir unless workdir.nil?
  end

  def create_thumbnail(path, height, save_to)
    img = ::Magick::Image.read(path).first
    img.format = "JPEG"

    factor = height.to_f / img.rows
    img.scale!(factor)
    img.write(save_to) { self.quality = 75 }
  end

end
