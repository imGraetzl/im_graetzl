RSpec.shared_examples :a_post do
  let(:post_class) { described_class.name.underscore.to_sym }

  describe 'validations' do
    it 'is invalid without title' do
      expect(build post_class, title: nil)
    end

    it 'is invalid without author' do
      expect(build post_class, author: nil)
    end
  end

  describe 'associations' do
    let(:post) { create post_class }

    it 'has author' do
      expect(post).to respond_to(:author)
    end

    describe 'comments' do
      it 'has comments' do
        expect(post).to respond_to(:comments)
      end

      it 'destroys comments' do
        create_list :comment, 3, commentable: post
        expect{post.destroy}.to change{Comment.count}.from(3).to 0
      end
    end

    describe 'images' do
      it 'has images' do
        expect(post).to respond_to(:images)
      end

      it 'destroys images' do
        create_list(:image, 3, imageable: post)
        expect{post.destroy}.to change{Image.count}.from(3).to 0
      end
    end
  end
end
