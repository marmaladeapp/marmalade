module Constraints
  class ShortDispatcher
    def initialize(router)
      @router = router
    end
    def call(env)
      id     = env["action_dispatch.request.path_parameters"][:id]
      slug   = VanityUrl.find_by_slug(id) # id.downcase
      # id.downcase - why? So that /ThomBruce and /thombruce resolve to same address
      # currently slugs are parameterized such that when you call resource.slug, it's downcase anyway
      # ...but you don't need to. You just do need to ensure that the rule is enforced consistently
      # on whichever model uses it. It's friendly_id extension needs the rule set correctly.
      Render.new(slug).call(@router, env)
    end

    private

    class Render
      def initialize(url)
        @url = url
      end
      def call(router, env)
        routing    = Rails.application.routes.recognize_path(@url.target)
        controller = (routing[:controller] + "_controller").classify.constantize
        action     = routing[:action]
        env["action_dispatch.request.path_parameters"] = routing
        controller.action(action).call(env)
      end
    end
  end
end
