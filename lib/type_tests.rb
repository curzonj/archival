module TypeTests
  GRAPHICS_FORMATS = [ 'image/jpeg', 'image/gif', 'image/png' ]

  def is_pdf?
    content_type == "application/pdf"
  end

  def is_portable_bitmap?
    content_type.match /portable/
  end

  def is_graphic?
    GRAPHICS_FORMATS.include?(content_type)
  end
end
