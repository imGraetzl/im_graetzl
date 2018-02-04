require 'rails_helper'

RSpec.describe PostsController, type: :routing do
  describe 'routes ' do
    it 'does not route POST graetzl-slug/posts' do
      expect(post: '/graetzl-slug/posts').not_to route_to('posts#create')
    end

    it 'does not route GET graetzl-slug/posts/new' do
      expect(get: '/graetzl-slug/posts/new').not_to route_to('posts#new')
    end
  end

end
