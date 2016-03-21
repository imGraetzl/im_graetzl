module LocationPostsHelper
  def load_more_comments_link(commentable)
    link_to 'Ältere Kommentare zeigen',
      [commentable, :comments],
      remote: true,
      data: { disable_with: 'lädt...', behavior: "comments-link-#{commentable.id}" },
      rel: 'nofollow',
      class: 'link-loadcomments'
  end
end
