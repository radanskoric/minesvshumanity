# Do not use the methods directly, intended to be used only through the
# Turbo Stream Tag Builder.
#
# @example:
#   turbo_stream.custom_action target: "my-target", template: "<div>Hello World</div>"
module TurboStreamActionsHelper
  # Like standard replace action, but first checks the data-version attribute on the target element
  # and on the payload and only replaces the element if the payload version is larger.
  # This prevents race conditions when broadcasting these updates since the receival order is not
  # guaranteed.
  def versioned_replace(target, content = nil, **rendering, &block)
    template = render_template(target, content, allow_inferred_rendering: true, **rendering, &block)

    turbo_stream_action_tag :versioned_replace, target: target, method: :morph, template: template
  end
end
Turbo::Streams::TagBuilder.include(TurboStreamActionsHelper)
