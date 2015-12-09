module CommentsHelper
  def comment_outer_wrapper(comment)
    comment.inline ? '' : 'streamElement'
  end

  def comment_wrapper(comment)
    comment.inline ? 'entryUserComment' : 'entryInitialContent'
  end

  def render_inline_comment(comment)
    comment.inline = true
    render comment
  end

  def link_to_load_comments(commentable)
    link_to 'Ältere Kommentare zeigen', [commentable, :comments],
                                      remote: true,
                                      data: { disable_with: 'lädt...' },
                                      rel: 'nofollow',
                                      class: 'link-loadcomments'

  end
end
