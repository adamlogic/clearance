class CreateOrUpdateUsersWithClearanceColumns < ActiveRecord::Migration
  def self.up
<% 
      existing_columns = ActiveRecord::Base.connection.columns(:users).collect { |each| each.name }
      columns = [
        [:email,                     't.string :email'],
        [:encrypted_password,        't.string :encrypted_password, :limit => 128'],
        [:salt,                      't.string :salt, :limit => 128'],
        [:remember_token,            't.string :remember_token'],
        [:remember_token_expires_at, 't.datetime :remember_token_expires_at'],
        [:email_confirmed,           't.boolean :email_confirmed, :default => false, :null => false'],
        [:locked,                    't.boolean :locked, :default => false, :null => false'],
        [:authentication_failures,   't.integer :authentication_failures, :default => 0']
      ].delete_if {|c| existing_columns.include?(c.first.to_s)} 
-%>
    change_table(:users) do |t|
<% columns.each do |c| -%>
      <%= c.last %>
<% end -%>
    end
    
<%
    existing_indexes = ActiveRecord::Base.connection.indexes(:users)
    index_names = existing_indexes.collect { |each| each.name }
    new_indexes = [
      [:index_users_on_email_and_encrypted_password, 'add_index :users, [:email, :encrypted_password]'],
      [:index_users_on_id_and_salt,                  'add_index :users, [:id, :salt]'],
      [:index_users_on_email,                        'add_index :users, :email'],
      [:index_users_on_remember_token,               'add_index :users, :remember_token']
    ].delete_if { |each| index_names.include?(each.first.to_s) }
-%>
<% new_indexes.each do |each| -%>
    <%= each.last %>
<% end -%>
  end
  
  def self.down
    change_table(:users) do |t|
<% unless columns.empty? -%>
      t.remove <%= columns.collect { |each| ":#{each.first}" }.join(',') %>
<% end -%>
    end
  end
end
