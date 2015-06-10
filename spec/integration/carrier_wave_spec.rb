class TestUploader < CoverPhotoUploader
  def uploader_options
    {
      :ignore_processing_errors => false,
      :ignore_integrity_errors => false
    }
  end

  def model
    @m ||= Object.new
    class << @m
      def id; 1; end;
    end
    @m
  end
end

RSpec.describe "CarrierWave Integration" do
  it "should process images with MiniMagick without raising CarrierWave::ProcessingError" do
    uploader = TestUploader.new
    
    File.open(File.join(Rails.root, 'spec', 'support', 'cover_photo_test.png')) do |f|
      expect { uploader.store!(f) }.not_to raise_error
    end        
  end
end
