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
            settings = Setting[:plugin_redmine_required_field]
            rrf_projects = settings[:time_entry][:required_project]
            rrf_all_project_required = settings[:time_entry][:all_project_required].to_i
            should_decide_to_check = (rrf_all_project_required == 1) || (rrf_projects[@issue.project.id.to_s].to_i == 1)

            if should_decide_to_check
              status = IssueStatus.find(params[:issue][:status_id])
              check_all_status = settings[:time_entry][:all_status_required].to_i == 1
              check_closed_status = settings[:time_entry][:closed_status_required].to_i == 1
              required_status = settings[:time_entry][:required_status]

              if check_all_status
                rrf_check = true
              elsif check_closed_status && status.is_closed
                rrf_check = true
              else
                rrf_check = required_status[status.id.to_s].to_i == 1
              end
            end
          end

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

