Sequel.migration do
  up do
    create_table :route_mappings do
      VCAP::Migration.common(self)

      foreign_key :app_id, :apps
      foreign_key :route_id, :routes
      Integer :app_port
    end

    # Migrate apps_routes records into new table
    self[:apps_routes]
      .select(:app_id, :route_id, :apps__ports)
      .join(:apps, id: :app_id)
      .map do |columns|
      # dont user integer array serializer here since this migration might be
      # run a long time in the future, when that class has been renamed or
      # removed
      raw_string = columns[:ports]
      ports = raw_string && raw_string.split(',').map(&:to_i)
      port = ports && ports.first
      mapping = [columns[:app_id], columns[:route_id], port, SecureRandom.uuid]
      self[:route_mappings].insert([:app_id, :route_id, :app_port, :guid], mapping)
    end
  end

  down do
    # self[:apps_routes].insert([:app_id, :route_id],
    #                           self[:route_mappings].select(:app_id, :route_id))

    drop_table(:route_mappings)
  end
end
