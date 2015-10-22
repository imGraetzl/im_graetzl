module MetaTagHelper
  META_TAGS = [:description, :robots]
  OG_TAGS = [:title, :description, :image]

  def title(page_title)
    content_for(:title) { "#{page_title} | "}
  end

  def canonical_tag
    tag(:link, rel: 'canonical', href: "http://#{request.host + request.fullpath}".gsub(/\/$/, ""))    
  end

  def meta(tags_hash, type=:meta)
    tags_hash.each do |tag, content|
      case
      when tag == :title
        title(content)
      when tag =~ /og_/
        og_tag(tag[3..-1], content)
      else
        meta_tag(tag, content)
      end
    end
  end

  private

  def meta_tag(name, content)
    content_for :"meta_#{name.to_s}" do
      tag(:meta, name: name.to_s, content: content)
    end
  end

  def og_tag(name, content)
    content_for :"og_#{name.to_s}" do
      tag(:meta, property: "og:#{name}", content: content)
    end
  end
end
