require_dependency 'issues_controller'


module RedmineRequiredField
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method_chain :update, :redmine_required_field
        end
      end

      module InstanceMethods

        def update_with_redmine_required_field
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
            flash[:error] = l('redmine_required_field.time_entry_is_required')
            find_issue
            update_issue_from_params
            render :action => 'edit'

            return
          end

          update_without_redmine_required_field
        end


        private


        def rrf_params_match_settings(rrf_setting)
          rrf_params_match_setting_for_id(rrf_setting[RedmineRequiredField::PROJECT_IDS], @issue.project_id) &&
            rrf_params_match_setting_for_id(rrf_setting[RedmineRequiredField::ISSUE_STATUS_IDS], params[:issue][:status_id]) &&
            rrf_params_match_setting_for_id(rrf_setting[RedmineRequiredField::TRACKER_IDS], params[:issue][:tracker_id])
        end

        def rrf_params_match_setting_for_id(rrf_setting, value)
          return true if rrf_setting.blank?
          return true if value.blank?

          rrf_setting.map(&:to_i).include?(value.to_i)
        end

      end
    end
  end
end

