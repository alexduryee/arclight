# frozen_string_literal: true

module Arclight
  # Controller for our /repositories index page
  class RepositoriesController < ApplicationController
    def index
      @repositories = Arclight::Repository.all
      load_collection_counts
    end

    private

    def load_collection_counts
      counts = fetch_collection_counts
      @repositories.each do |repository|
        repository.collection_count = counts[repository.name] || 0
      end
    end

    def fetch_collection_counts
      search_service = Blacklight.repository_class.new(blacklight_config)
      results = search_service.search(
        q: 'level_sim:Collection',
        'facet.field': 'repository_sim',
        rows: 0
      )
      Hash[*results.facet_fields['repository_sim']]
    end
  end
end
