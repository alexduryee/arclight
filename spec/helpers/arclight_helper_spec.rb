# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ArclightHelper, type: :helper do
  let(:params) { {} }
  let(:search_state) do
    Blacklight::SearchState.new(params, CatalogController.blacklight_config)
  end

  before do
    allow(helper).to receive(:search_state).and_return(search_state)
  end

  describe '#collection_active?' do
    context 'with active collection search' do
      let(:params) do
        { 'f' => { 'level_sim' => ['Collection'] } }
      end

      it do
        expect(helper.collection_active?).to be true
      end
    end

    context 'without active collection search' do
      before do
        allow(helper).to receive(:search_state).and_return(search_state)
      end

      it do
        expect(helper.collection_active?).to be false
      end
    end
  end

  describe '#grouped?' do
    context 'when group is active' do
      let(:params) do
        { 'group' => 'true' }
      end

      before do
        allow(helper).to receive(:search_state).and_return(search_state)
      end

      it do
        expect(helper.grouped?).to be_truthy
      end
    end

    context 'when not grouped' do
      let(:params) do
        { 'hello' => 'true' }
      end

      before do
        allow(helper).to receive(:search_state).and_return(search_state)
      end

      it do
        expect(helper.grouped?).to be_falsey
      end
    end
  end

  describe '#search_with_group' do
    let(:params) do
      { 'q' => 'hello', 'page' => '2' }
    end

    it do
      expect(helper.search_with_group).to eq(
        'q' => 'hello',
        'group' => 'true'
      )
    end
  end

  describe '#search_without_group' do
    let(:params) do
      { 'q' => 'hello', 'group' => 'true', 'page' => '2' }
    end

    it do
      expect(helper.search_without_group).to eq(
        'q' => 'hello'
      )
    end
  end

  describe '#on_repositories_index?' do
    before { allow(helper).to receive(:action_name).twice.and_return('index') }

    context 'with repositories index' do
      it do
        allow(helper).to receive(:controller_name).twice.and_return('repositories')
        expect(helper.on_repositories_index?).to be true
        expect(helper.repositories_active_class).to eq 'active'
      end
    end

    context 'without repositories index' do
      it do
        allow(helper).to receive(:controller_name).twice.and_return('NOT repositories')
        expect(helper.on_repositories_index?).to be false
        expect(helper.repositories_active_class).to be_nil
      end
    end
  end

  describe '#on_repositories_show?' do
    before { allow(helper).to receive(:action_name).twice.and_return('show') }

    context 'with repositories show' do
      it do
        allow(helper).to receive(:controller_name).twice.and_return('repositories')
        expect(helper.on_repositories_show?).to be true
        expect(helper.repositories_active_class).to be_nil
      end
    end

    context 'without repositories show' do
      it do
        allow(helper).to receive(:controller_name).twice.and_return('NOT repositories')
        expect(helper.on_repositories_show?).to be false
        expect(helper.repositories_active_class).to be_nil
      end
    end
  end

  describe '#collection_count' do
    context 'when there are items' do
      it 'returns the item count from the Blacklight::Solr::Response' do
        assign(:response, instance_double(Blacklight::Solr::Response, response: { 'numFound' => 2 }))

        expect(helper.collection_count).to eq 2
      end
    end

    context 'when there are no items' do
      it do
        assign(:response, instance_double(Blacklight::Solr::Response, response: {}))
        expect(helper.collection_count).to be_nil
      end
    end
  end

  describe '#search_results_header_text' do
    subject(:text) { helper.search_results_header_text }

    let(:blacklight_config) { CatalogController.blacklight_config }
    let(:search_state) { Blacklight::SearchState.new(params, blacklight_config) }
    let(:params) { {} }

    before do
      allow(helper).to receive(:search_state).and_return(search_state)
    end

    context 'when searching within a repository' do
      let(:params) { { 'f' => { 'repository_sim' => ['My Repository'] } } }

      it { expect(text).to eq 'Collections : [My Repository]' }
    end

    context 'when searching all collections' do
      let(:params) { { 'f' => { 'level_sim' => ['Collection'] } } }

      it { expect(text).to eq 'Collections' }
    end

    context 'all other non-special search behavior' do
      it { expect(text).to eq 'Search' }
    end
  end

  describe 'document_or_parent_icon' do
    let(:document) { SolrDocument.new(level_ssm: ['collection']) }

    it 'properly assigns the icon' do
      expect(helper.document_or_parent_icon(document)).to eq 'collection'
    end

    context 'there is no level_ssm' do
      let(:document) { SolrDocument.new }

      it 'gives the default icon' do
        expect(helper.document_or_parent_icon(document)).to eq 'container'
      end
    end
  end

  describe '#hierarchy_component_context?' do
    it 'requires a parameter to enable' do
      allow(helper).to receive(:params).and_return(hierarchy_context: 'component')
      expect(helper.hierarchy_component_context?).to be_truthy
    end

    it 'omission is disabled' do
      allow(helper).to receive(:params).and_return({})
      expect(helper.hierarchy_component_context?).to be_falsey
    end
  end
end
