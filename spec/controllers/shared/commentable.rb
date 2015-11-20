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

  it 'renders create.js' do
    expect(response['Content-Type']).to include('text/javascript')
    expect(response).to render_template(:create)
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

  it 'creates new activity record', job: true do
    expect {
      PublicActivity.with_tracking { xhr :post, :create, params }
    }.to change(PublicActivity::Activity, :count).by(1)
  end
end

RSpec.shared_examples :inline_comment do
  before { params.merge!(inline: 'true') }

  include_examples :create_records

  describe 'request', job: true do
    before do
      PublicActivity.with_tracking { xhr :post, :create, params }
    end

    it 'assigns @inline true' do
      expect(assigns(:inline)).to eq true
    end

    include_examples :a_successfull_create_request
  end
end

RSpec.shared_examples :stream_comment do
  before { params.merge!(inline: 'false') }

  include_examples :create_records

  describe 'request', job: true do
    before do
      PublicActivity.with_tracking { xhr :post, :create, params }
    end

    it 'assigns @inline false' do
      expect(assigns(:inline)).to eq false
    end

    include_examples :a_successfull_create_request
  end
end
