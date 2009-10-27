# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def list_by(number, list)
    duplist = list.dup
    while duplist.size > 0
      current_set = []
      number.times do
        v = duplist.shift
        current_set << v unless v.nil?
      end

      yield current_set
    end
  end

  def res_attr(res, name, key)
    value = res.send(key)

    unless value.blank?
      "<strong>#{name}: </strong>" +
      (block_given? ? yield(value) : value).to_s +
      "<br/>"
    end
  end

  def image_tag_if(value)
    unless value.nil?
      image_tag(value)
    end
  rescue
    nil
  end
end
