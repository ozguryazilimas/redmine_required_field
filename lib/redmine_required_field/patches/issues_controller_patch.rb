require_dependency 'issues_controller'

module RedmineRequiredField
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          alias_method_chain :update, :redmine_required_field
        end
      end

      module ClassMethods
      end

      module InstanceMethods

        def update_with_redmine_required_field
          rrf_check = false

          if params.has_key?(:time_entry)
            settings = Setting[:plugin_redmine_required_field][:time_entry]
            rrf_projects = settings[:required_project]
            rrf_all_project_required = settings[:all_project_required]
            should_decide_to_check = rrf_all_project_required || rrf_projects[@issue.project.id.to_s]
            Rails.logger.debug "RRF should_decide_to_check #{should_decide_to_check.inspect}"

            if should_decide_to_check
              status = IssueStatus.find(params[:issue][:status_id])
              check_all_status = settings[:all_status_required]
              check_closed_status = settings[:closed_status_required]
              required_status = settings[:required_status]

              if check_all_status
                rrf_check = true
              elsif check_closed_status && status.is_closed
                rrf_check = true
              else
                rrf_check = required_status[status.id.to_s]
              end
            end
          end

          Rails.logger.debug "RRF rrf_check #{rrf_check.inspect}"
          if rrf_check && params[:time_entry][:hours].blank?
            flash[:error] = l('time_entry.time_entry_is_required')
            find_issue
            update_issue_from_params
            render(:action => 'edit') && return
          end

          update_without_redmine_required_field
        end

      end

    end
  end
end

