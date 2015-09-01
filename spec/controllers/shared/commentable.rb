RSpec.shared_examples :a_successfull_create_request do

  it 'assigns @commentable' do
    expect(assigns(:commentable)).to eq(resource)
  end

  describe 'new comment' do
    subject(:new_comment) { Comment.last }

    it 'has resource as commentable' do
      expect(new_comment.commentable).to eq resource
    end

    it 'has current_user as user' do
      expect(new_comment.user).to eq user
    end
  end
end

RSpec.shared_examples :inline_comment do
  before { params.merge!(inline: 'true') }

  it 'creates new comment' do
    expect {
      xhr :post, :create, params
    }.to change(Comment, :count).by(1)
  end

  describe 'request' do
    render_views
    before { xhr :post, :create, params }          

    include_examples :a_successfull_create_request

    it 'renders comment partial' do
      expect(response).to render_template(partial: 'comments/_comment')
    end

    it 'does not render stream layout' do
      expect(response.body).not_to have_selector('div.streamElement')
    end
  end
end

RSpec.shared_examples :stream_comment do

  it 'creates new comment' do
    expect {
      xhr :post, :create, params
    }.to change(Comment, :count).by(1)
  end

  describe 'request' do
    render_views
    before { xhr :post, :create, params }

    include_examples :a_successfull_create_request    

    it 'renders comment partial' do
      expect(response).to render_template(partial: 'comments/_comment')
    end

    it 'renders stream layout' do
      expect(response.body).to have_selector('div.streamElement')
    end
  end
end