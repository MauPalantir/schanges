require_relative 'spec_helper'
require_relative '../lib/schanges'

describe SoundChanges::Applier do
  subject { described_class.new(options) }

  let(:stages) do
    {
      'stage1' => {
        changes: [
          'S=ptk',
          'Z=bdg',
          'V=aiu',
          'S/Z/V_V'
        ],
        words: %w(apata kita patak)
      },
      'stage2' => {
        changes: [
          'V//Z_',
          'V//_S'
        ],
        words: %w(kutu)
      },
      'stage3' => {
        changes: [
          'Z/Zo/Z_#'
        ],
        words: []
      }
    }
  end

  context 'absolute original' do
    before(:each) do
      stages.each do |name, data|
        subject.add_stage(name, data[:words], data[:changes])
      end
    end
    let(:options) { { original: 'absolute' } }
    let(:output_words) do
      {
        'stage1' => {
          'apata' => { word: 'abada', gloss: nil },
          'kita' => { word: 'kida', gloss: nil },
          'patak' => { word: 'padak', gloss: nil }
        },
        'stage2' => {
          'apata' => { word: 'abd', gloss: nil },
          'kita' => { word: 'kid', gloss: nil },
          'patak' => { word: 'padk', gloss: nil },
          'kutu' => { word: 'ktu', gloss: nil }
        },
        'stage3' => {
          'apata' => { word: 'abdo', gloss: nil },
          'kita' => { word: 'kid', gloss: nil },
          'patak' => { word: 'padk', gloss: nil },
          'kutu' => { word: 'ktu', gloss: nil }
        }
      }
    end

    it 'shows the first stage words as original' do
      expect(subject.apply).to eq output_words
    end
  end

  context 'relative or no original' do
    before(:each) do
      stages.each do |name, data|
        subject.add_stage(name, data[:words], data[:changes])
      end
    end
    let(:options) { {} }
    let(:output_words) do
      {
        'stage1' => {
          'apata' => { word: 'abada', gloss: nil },
          'kita' => { word: 'kida', gloss: nil },
          'patak' => { word: 'padak', gloss: nil }
        },
        'stage2' => {
          'abada' => { word: 'abd', gloss: nil },
          'kida' => { word: 'kid', gloss: nil },
          'padak' => { word: 'padk', gloss: nil },
          'kutu' => { word: 'ktu', gloss: nil }
        },
        'stage3' => {
          'abd' => { word: 'abdo', gloss: nil },
          'kid' => { word: 'kid', gloss: nil },
          'padk' => { word: 'padk', gloss: nil },
          'ktu' => { word: 'ktu', gloss: nil }
        }
      }
    end
    it 'shows intermediate stages as original' do
      expect(subject.apply).to eq output_words
    end
  end

  it 'produces the same output words' do
    relative = described_class.new({})
    absolute = described_class.new(original: 'absolute')
    stages.each do |s, d|
      relative.add_stage(s, d[:words], d[:changes])
      absolute.add_stage(s, d[:words], d[:changes])
    end
    relative_words_path = relative.apply.values.collect(&:values).flatten
    absolute_words_path = absolute.apply.values.collect(&:values).flatten

    expect(relative_words_path).to eq absolute_words_path
  end
end
