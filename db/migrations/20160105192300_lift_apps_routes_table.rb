Sequel.migration do
  up do

    alter_table :apps_routes do
      add_column :created_at, :timestamp, null: false, default: Sequel::CURRENT_TIMESTAMP
      add_column :updated_at, :timestamp
      add_column :app_port, Integer
      add_column :id, Integer, auto_increment: true, primary_key: true
    end

    if self.class.name.match /mysql/i
      run 'ALTER TABLE APPS_ROUTES ADD COLUMN guid varchar(255) default UUID();'
    end

    self[:apps_routes]
      .select(:app_id, :route_id, :apps__ports)
      .join(:apps, id: :app_id)
      .each do |row|
      raw_string = row[:ports]
      ports = raw_string && raw_string.split(',').map(&:to_i)
      port = ports && ports.first
      self[:apps_routes]
        .filter(route_id: row[:route_id], app_id: row[:app_id])
        .update(guid: SecureRandom.uuid, app_port: port)
    end

    alter_table :apps_routes do
      #set_column_not_null :guid
      created_at_idx = "apps_routes_created_at_index".to_sym
      updated_at_idx = "apps_routes_updated_at_index".to_sym
      guid_idx = "apps_routes_guid_index".to_sym
      add_index :updated_at, name: updated_at_idx
      add_index :guid, unique: true, name: guid_idx
      add_index :created_at, name: created_at_idx
    end
  end

  down do
    alter_table :apps_routes do
      created_at_idx = "apps_routes_created_at_index".to_sym
      updated_at_idx = "apps_routes_updated_at_index".to_sym
      guid_idx = "apps_routes_guid_index".to_sym
      drop_index :guid, name: guid_idx
      drop_index :updated_at, name: updated_at_idx
      drop_index :created_at, name: created_at_idx

      drop_column :guid
      drop_column :app_port
      drop_column :updated_at
      drop_column :created_at
      drop_column :id
    end
  end
end