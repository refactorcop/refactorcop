class ChangeRubocopOffenseMessageToText < ActiveRecord::Migration
  def change
    change_table :rubocop_offenses do |t|
      t.change :message, :text
    end
  end
end
