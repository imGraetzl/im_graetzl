RSpec.shared_examples :a_district_controller do
  it 'has name districts' do
    expect(described_class.controller_name).to eq 'districts'
  end
end
