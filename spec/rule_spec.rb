require_relative '../lib/schanges/character_class'
require_relative '../lib/schanges/rule'

shared_examples_for 'a rule' do |examples|
  examples.each do |input, output|
    it("'#{input}' > '#{output}'") { expect(rule.apply(input)).to eq output }
  end
end

describe SoundChanges::Rule do
  subject { described_class }
  rules =
    [
      't/s/V_V',
      't/s/_#',
      'S/Z/#_',
      'a/o/_w',
      'B/F/_…i',
      'V/Á/_w',
      'y/er/V_V#',
      'w//Á_',
      'w/u/_[ei]'
    ]
  before { SoundChanges::CharacterClass.reset }

  context 'support character classes' do
    let(:rule) { subject.new(%w(A Á _)) }
    examples = {
      'karu' => 'kárú', 'ushu' => 'úshú', 'oya' => 'óyá'
    }

    before do
      SoundChanges::CharacterClass.add 'A', 'aeiou'
      SoundChanges::CharacterClass.add 'Á', 'áéíóú'
    end

    it_behaves_like 'a rule', examples

    context 'in contexts' do
      before { SoundChanges::CharacterClass.add 'L', 'lry' }
      let(:rule) { subject.new(%w(A Á _L)) }
      examples = {
        'karu' => 'káru',
        'ushur' => 'ushúr',
        'oyar' => 'óyár'
      }
      it_behaves_like 'a rule', examples
    end
  end

  context 'support # as word beginning' do
    let(:rule) { subject.new(%w(a e #_)) }
    examples = {
      'ara' => 'era', 'kara' => 'kara'
    }

    it_behaves_like 'a rule', examples
  end

  context 'support # as word ending' do
    let(:rule) { subject.new(%w(a e _#)) }
    examples = {
      'ara' => 'are', 'kare' => 'kare'
    }

    it_behaves_like 'a rule', examples
  end

  context 'support … as someting later in a word' do
    let(:rule) { subject.new(%w(a e _…i)) }
    examples = {
      'arewi' => 'erewi', 'karammi' => 'keremmi'
    }

    it_behaves_like 'a rule', examples
  end

  context 'support mixed letters and classes in to' do
    before do
      SoundChanges::CharacterClass.add 'A', 'aeiou'
      SoundChanges::CharacterClass.add 'Á', 'áéíóú'
    end

    let(:rule) { subject.new(%w(A eÁ _#)) }
    examples = {
      'ara' => 'areá', 'kiyu' => 'kiyeú'
    }

    it_behaves_like 'a rule', examples
  end

  context 'dont try to replace classes that dont have an equivalent in from' do
    before do
      SoundChanges::CharacterClass.add 'A', 'aeiou'
      SoundChanges::CharacterClass.add 'Á', 'áéíóú'
    end

    let(:rule) { subject.new(%w(i eÁy _)) }
    examples = {
      'arai' => 'araeÁy', 'kiyu' => 'keÁyyu'
    }

    it_behaves_like 'a rule', examples
  end

  context 'dont try to replace classes that dont have an equivalent in from' do
    before do
      SoundChanges::CharacterClass.add 'A', 'aeiou'
      SoundChanges::CharacterClass.add 'Á', 'áéíóú'
    end

    let(:rule) { subject.new(%w(iA eÁyA _)) }
    examples = {
      'ioma' => 'eóyama', 'kiuyu' => 'keúyayu'
    }

    it_behaves_like 'a rule', examples
  end

  context 'implements temporary classes' do
    let(:rule) { subject.new %w(i e _[tsz]) }
    examples = { 'isaka' => 'esaka', 'virait' => 'viraet', 'azizi' => 'azezi' }

    it_behaves_like 'a rule', examples
  end

  context 'reckognizes optional context class' do
    before { SoundChanges::CharacterClass.add 'V', 'aie' }
    before { SoundChanges::CharacterClass.add 'C', 'skn' }

    let(:rule) { subject.new %w(i e _(C)V) }
    examples = {
      'isaka' => 'esaka', 'viain' => 'veain', 'ainna' => 'ainna'
    }

    it_behaves_like 'a rule', examples

    context 'with simple characters' do
      let(:rule) { subject.new %w(i e _(na)C) }
      examples = {
        'inaka' => 'enaka', 'visin' => 'vesen', 'aianna' => 'aianna'
      }

      it_behaves_like 'a rule', examples
    end
  end
end
