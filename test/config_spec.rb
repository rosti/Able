include Able

describe Configuration, '#find_rule_by' do
  it 'confirms that nil is reported on no match' do
    config = Configuration.new :default
    config << Rule.new('named rule')
    config << Rule.new('.o' => '.c')
    config.find_rule_by(:input => '.cpp').should be_nil
  end

  it 'confirms that the matching rule is reported' do
    config = Configuration.new :default
    config << Rule.new('named rule')
    config << Rule.new('.o' => '.c')
    config.find_rule_by(:name => 'named rule').name.should == 'named rule'
  end
end
