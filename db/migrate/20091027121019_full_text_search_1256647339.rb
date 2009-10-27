class FullTextSearch1256647339 < ActiveRecord::Migration
  def self.up
      ActiveRecord::Base.connection.execute(<<-'eosql')
        DROP index IF EXISTS documents_fts_idx
      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
                CREATE index documents_fts_idx
        ON documents
        USING gin((to_tsvector('english', coalesce(documents.subject, '') || ' ' || coalesce(documents.predicate, '') || ' ' || coalesce(documents.notes, '') || ' ' || coalesce(documents.tags, ''))))

      eosql
  end
end
