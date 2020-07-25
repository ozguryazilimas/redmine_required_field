require_dependency 'settings_controller'


module RedmineRequiredField
  module Patches
    module SettingsControllerPatch

      def plugin
        original_plugin_action = super

        if params[:id].to_s == RedmineRequiredField::PLUGIN_NAME && params[:settings].present?
          raw_data = params[:settings][RedmineRequiredField::ISSUE_REQUIRED].presence || '[]'
          params[:settings][RedmineRequiredField::ISSUE_REQUIRED] = JSON.parse(raw_data) rescue []
        end

        original_plugin_action
      end

    end
  end
end

SettingsController.prepend(RedmineRequiredField::Patches::SettingsControllerPatch)

