module ROM
  module HTTP
    class Relation < ROM::Relation
      include Enumerable

      adapter :http

      forward :with_request_method, :with_path, :prepend_path, :append_path,
              :with_options, :with_params, :clear_params
    end
  end
end
