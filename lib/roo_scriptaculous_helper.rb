module RooScriptaculousHelper
  def hide_if_js(id)
    "<script type=\"text/javascript\">
      Element.hide(\"#{id}\");
    </script>"
  end

  def hide(id)
    "if (Element.visible('#{id}')){Effect.BlindUp('#{id}', {duration:0.5});};"
  end

  def show(id)
    "if (!Element.visible('#{id}')){Effect.BlindDown('#{id}', {duration:0.5});};"
  end

  def toggle(id)
    "Effect.toggle('#{id}', 'blind', {duration:0.5});"
  end

  def reset_form_elements(prefix, elements)
    update_page do |page|
      elements.each {|e| page["#{prefix}_#{e}"].value = ''}
    end
  end

  def replace_html(id, contents)
    update_page do |page|
      page.replace_html "#{id}", contents
    end
  end

  def toggle_html(visible_id, id, shown, hidden)
    "if (Element.visible('#{visible_id}')) {" + replace_html(id, shown) + "} else {" + replace_html(id, hidden) + "};"
  end
end