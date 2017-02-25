shared_examples :meetings_new do
  it 'assign @meeting in user graetzl' do
    expect(assigns :meeting).to have_attributes(graetzl: graetzl)
  end

  it 'renders meetings/new' do
    expect(response).to render_template 'meetings/new'
  end
end
shared_examples :meetings_create do
  it 'assigns new @meeting' do
    post :create, params: params
    expect(assigns :meeting).to be_a Meeting
  end

  it 'creates new meeting' do
    expect{
      post :create, params: params
    }.to change{Meeting.count}.by 1
  end

  it 'logs an activity' do
    expect{
      post :create, params: params
    }.to change{Activity.count}.by 1
  end

  it 'creates a new going to' do
    expect{
      post :create, params: params
    }.to change{GoingTo.count}.by 1
  end

  it 'redirects to meeting in graetzl' do
    post :create, params: params
    expect(response).to redirect_to [graetzl, Meeting.last]
  end
end
