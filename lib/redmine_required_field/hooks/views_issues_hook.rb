module RedmineRequiredField
  module Hooks
    class ViewsIssuesHook < Redmine::Hook::ViewListener

      render_on :view_issues_form_details_bottom, :partial => 'issues/form_rrf_redmine_required_field'

    end
  end
end

