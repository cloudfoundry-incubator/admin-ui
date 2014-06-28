Sequel.migration do
  transaction

  up do
    create_table :stats do
      Integer :apps
      Integer :deas
      Integer :organizations
      Integer :running_instances
      Integer :spaces
      Timestamp :timestamp, :primary_key => true
      Integer :total_instances
      Integer :users
    end
  end

  down do
    drop_table :stats
  end
end
