module VCAP::CloudController
  class RouteMapping < Sequel::Model(:apps_routes)
    set_primary_key [:app_id, :route_id]
    many_to_one :app
    many_to_one :route

    export_attributes :app_port, :app_guid, :route_guid

    import_attributes :app_port, :app_guid, :route_guid

    # DATASET = App.dataset.join(:apps_routes, app_id: :id).select(:apps_routes__route_id, :apps_routes__app_id)
    # set_dataset(DATASET)

    def validate
      if self.app_port && !app.diego
        errors.add(:app_port, :diego_only)
      elsif app.diego && self.app_port && !app.ports.include?(self.app_port)
        errors.add(:app_port, :not_bound_to_app)
      end
      super
    end

    def before_save
      if !self.app_port && app.diego
        self.app_port = app.ports.first
      end
      super
    end

    def before_create
      app.validate_route(route)
      super
    end

    def after_create
      app.handle_add_route(route)
      super
    end

    # TODO: test app.handle_remove_app
  end
end
