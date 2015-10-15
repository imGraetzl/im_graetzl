module SeoHelper
  def title(page_title)
    content_for(:title) { "#{page_title} | "}    
  end

  def meta_tag(name, content)
    content_for :"meta_#{name.to_s}" do
      tag(:meta, name: name.to_s, content: content)
    end
  end
end