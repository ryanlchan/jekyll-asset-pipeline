require './spec/helper'

describe VERSION do
  subject { JekyllAssetPipeline::VERSION }

  it "returns a string" do
    subject.must_be_instance_of String
  end
end
