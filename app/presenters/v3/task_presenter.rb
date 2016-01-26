module VCAP::CloudController
  class TaskPresenter
    def initialize(pagination_presenter=PaginationPresenter.new)
      @pagination_presenter                = pagination_presenter
    end

    def present_json(task)
      MultiJson.dump(task_hash(task), pretty: true)
    end

    def present_json_list(paginated_result, base_url, params)
      tasks       = paginated_result.records
      task_hashes = tasks.collect { |task| task_hash(task) }

      paginated_response = {
        pagination: @pagination_presenter.present_pagination_hash(paginated_result, base_url, params),
        resources:  task_hashes
      }

      MultiJson.dump(paginated_response, pretty: true)
    end

    private

    def task_hash(task)
      {
        guid:    task.guid,
        name:    task.name,
        command: task.command,
        state:   task.state,
        result:  { message: nil },
        links:   build_links(task)
      }
    end

    def build_links(task)
      {
        self:    { href: "/v3/tasks/#{task.guid}" },
        app:     { href: "/v3/apps/#{task.app.guid}" },
        droplet: { href: "/v3/droplets/#{task.droplet.guid}" },
      }
    end
  end
end
