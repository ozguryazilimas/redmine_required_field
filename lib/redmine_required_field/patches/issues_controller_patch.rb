require_dependency 'issues_controller'


module RedmineRequiredField
  module Patches
    module IssuesControllerPatch

      def update
        rrf_should_check_time_entry_hours = false

        if params.has_key?(:time_entry)
          Rails.logger.debug "RRF params has time_entry #{params[:time_entry].inspect}"

          rrf_settings = RedmineRequiredField.settings_issue_required
          rrf_should_check_time_entry_hours = rrf_settings.find do |rrf_setting|
            rrf_params_match_settings(rrf_setting)
          end.present?
        end

        Rails.logger.debug "RRF rrf_should_check_time_entry_hours #{rrf_should_check_time_entry_hours.inspect}"

        if rrf_should_check_time_entry_hours && params[:time_entry][:hours].blank?
          flash.now[:error] = l('redmine_required_field.spent_time_is_required_for_this_issue')
          find_issue
          update_issue_from_params
          render :action => 'edit'

          return
        end

        super
      end


      private


      def rrf_params_match_settings(rrf_setting)
        # check role and assignee behavior(negate match for given roles if checkbox is set, and only apply filter
        # if attached to only is set and user matches attached to )
        if rrf_setting[RedmineRequiredField::CHECK_ASSIGNEE_ONLY] == '1'
          return false if User.current.id != @issue.assigned_to_id
        end

        setting_role_ids = rrf_setting[RedmineRequiredField::ROLE_IDS]
        matched = RedmineRequiredField.setting_values_contain_ids(setting_role_ids, RedmineRequiredField.current_roles)

        if rrf_setting[RedmineRequiredField::ROLE_EXCLUDED] == '1'
          matched = !matched
        end

        return false unless matched

        setting_project_ids = rrf_setting[RedmineRequiredField::PROJECT_IDS]
        matched = RedmineRequiredField.setting_values_match_id(setting_project_ids, @issue.project_id)
        return false unless matched

        setting_tracker_ids = rrf_setting[RedmineRequiredField::TRACKER_IDS]
        matched = RedmineRequiredField.setting_values_match_id(setting_tracker_ids, params[:issue][:tracker_id])
        return false unless matched

        setting_issue_status_ids = rrf_setting[RedmineRequiredField::ISSUE_STATUS_IDS]
        matched = RedmineRequiredField.setting_values_match_id(setting_issue_status_ids, params[:issue][:status_id])

        matched
      end

    end
  end
end

IssuesController.prepend(RedmineRequiredField::Patches::IssuesControllerPatch)

