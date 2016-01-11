Sequel.migration do
  transaction

  up do
    add_column :stats, :cells, Integer
  end

  down do
    drop_column :status, :cells
  end
end
