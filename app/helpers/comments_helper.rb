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
end
