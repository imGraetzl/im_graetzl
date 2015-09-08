RSpec.shared_examples :a_successfull_create_request do

  it 'assigns @commentable' do
    expect(assigns(:commentable)).to eq(resource)
  end

  it 'assigns @comment' do
    expect(assigns(:commentable)).not_to be_nil
  end

  it 'logs create activity' do
    key = "#{resource.model_name.singular}.comment"
    expect(resource.reload.activities.last.key).to eq key
  end

  it 'renders comment partial' do
    expect(response).to render_template(partial: 'comments/_comment')
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

RSpec.shared_examples :create_records do
  it 'creates new comment' do
    expect {
      xhr :post, :create, params
    }.to change(Comment, :count).by(1)
  end

  it 'creates new activity record' do
    expect {
      PublicActivity.with_tracking { xhr :post, :create, params }
    }.to change(PublicActivity::Activity, :count).by(1)
  end
end

RSpec.shared_examples :inline_comment do
  before { params.merge!(inline: 'true') }

  include_examples :create_records

  describe 'request' do
    xhr_request_with_views

    include_examples :a_successfull_create_request

    it 'does not render stream layout' do
      expect(response.body).not_to have_selector('div.streamElement')
    end
  end
end

RSpec.shared_examples :stream_comment do

  include_examples :create_records

  describe 'request' do
    xhr_request_with_views

    include_examples :a_successfull_create_request

    it 'renders stream layout' do
      expect(response.body).to have_selector('div.streamElement')
    end
  end
end


# helper methods
def xhr_request_with_views
  render_views
  before { PublicActivity.with_tracking { xhr :post, :create, params } }  
end