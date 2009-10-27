class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table 'users' do |t|
      t.name
      t.string 'openid'
    end

    create_table 'documents' do |t|
      t.integer 'user_id'

      t.string  'subject'
      t.string  'predicate'
      t.date    'issued_on'
      t.text    'notes'
      t.string 'tags'

      t.string  'content_type'
      t.integer 'content_length'

      t.text 'cache'

      t.timestamps
    end
  end

  def self.down
  end
end
