include Able

describe Rule, '#matches_by?' do
  it 'returns true on a positive name match' do
    rule = Rule.new 'some_name'
    rule.matches_by?(:name => 'some_name').should be_true
  end

  it 'returns false on a negative name match' do
    rule = Rule.new 'some_name'
    rule.matches_by?(:name => 'other_name').should be_false
  end

  it 'returns false on a nameless rule' do
    rule = Rule.new '.c' => '.o'
    rule.matches_by?(:name => 'some_name').should be_false
  end

  it 'returns true on a input match' do
    rule = Rule.new '.c' => '.o'
    rule.matches_by?(:input => 'main.c').should be_true
  end

  it 'returns false on a input missmatch' do
    rule = Rule.new '.c' => '.o'
    rule.matches_by?(:input => 'main.cpp').should be_false
  end

  it 'returns false on a output missmatch' do
    rule = Rule.new '.c' => '.o'
    rule.matches_by?(:output => 'main.obj').should be_false
  end

  it 'returns true on a output missmatch' do
    rule = Rule.new '.c' => '.o'
    rule.matches_by?(:output => 'main.o').should be_true
  end

  it 'returns false on a output missmatch and named rule' do
    rule = Rule.new 'some_rule'
    rule.matches_by?(:output => 'main.o').should be_false
  end

  it 'returns false on a input missmatch and named rule' do
    rule = Rule.new 'some_rule'
    rule.matches_by?(:input => 'main.c').should be_false
  end

end

