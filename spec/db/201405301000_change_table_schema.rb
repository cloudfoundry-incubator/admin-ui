Sequel.migration do
  transaction

  up do
    alter_table(:stats) do
      add_column :extra_column, Integer, default: 0
    end
  end

  down do
    alter_table(:stats) do
      drop_column :extra_column
    end
  end
end
