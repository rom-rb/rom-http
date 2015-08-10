module ROM
  module HTTP
    class Relation < ROM::Relation
      include Enumerable

      adapter :http

      forward :with_request_method, :with_path, :append_path, :with_options,
              :with_params, :clear_params, :insert, :update, :delete
    end
  end
end
