require 'redmine'
require 'redmine_required_field'


Redmine::Plugin.register :redmine_required_field do
  name 'Redmine Required Field plugin'
  author 'Onur Kucuk'
  description 'Redmine plugin to customize how some issue fields will be required'
  version '0.9.1'
  url 'http://www.ozguryazilim.com.tr'
  author_url 'http://www.ozguryazilim.com.tr'
  requires_redmine :version_or_higher => '3.3.0'

  settings :partial => 'redmine_required_field/settings',
    :default => {
      :issue_required => []
    }
end


Rails.configuration.to_prepare do
  [
    [IssuesController, RedmineRequiredField::Patches::IssuesControllerPatch],
    [SettingsController, RedmineRequiredField::Patches::SettingsControllerPatch]
  ].each do |classname, modulename|
    unless classname.included_modules.include?(modulename)
      classname.send(:include, modulename)
    end
  end
end

