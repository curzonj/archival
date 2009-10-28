require 'type_tests'
require 'content_types'

class UploadedFile
  include Loggable
  include TypeTests

  def initialize(local)
    @local_path = local
    @work_dir = File.dirname(local)
  end

  def to_s
    @local_path
  end

  def pdf_images
    @pdf_images ||= if is_pdf?
      logger.info "Extracting pdf images from #{self}"
      images = extract_pdf_images

      # TODO pages shows the same number for everything in batch processing
      logger.debug "Extracted #{images.size} images from #{self}"
      if images.size < pdf_pages
        logger.warn "Only extracted #{images.size} images out of #{pdf_pages} for #{self}"
      end

      images
    else
      []
    end
  end

  def content_type
    @content_type ||= MIME::Types.content_type_for(@local_path)
  end

  def pdf_pages
    @pdf_pages ||= begin
      output = `pdfinfo #{@local_path}`
      match = output.match(/Pages:\s*(\d+)/)
      
      match[1].to_i unless match.nil?
    end
  end

  def extract_pdf_images
    base = "#{@work_dir}/extracted"

    `pdfimages -j #{@local_path} #{base}`

    Dir["#{base}*"].collect do |extract|
      case mime_type = MIME::Types.content_type_for(extract)
      when 'image/x-portable-bitmap', 'image/x-portable-pixmap'
        `pnmtojpeg #{extract} > #{extract}.jpg`
        extract + '.jpg'
      when 'image/jpeg', 'image/png', 'image/gif'
        extract
      else
        logger.warn "Failed to convert #{mime_type} to graphic format"
        next
      end
    end.compact
  end
end
