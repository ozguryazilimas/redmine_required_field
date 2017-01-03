require 'redmine'
require 'redmine_required_field'

Redmine::Plugin.register :redmine_required_field do
  name 'Redmine Required Field plugin'
  author 'Onur Kucuk'
  description 'Redmine plugin to customize how some issue fields will be required'
  version '0.1.0'
  url 'http://www.ozguryazilim.com.tr'
  author_url 'http://www.ozguryazilim.com.tr'
  requires_redmine :version_or_higher => '2.5.1'

  settings :partial => 'redmine_required_field/settings',
    :default => {
      :time_entry => {
        :required_project => {},
        :required_status => {},
        :closed_status_required => nil,
        :all_status_required => nil,
        :all_project_required => nil
      }
    }
end

Rails.configuration.to_prepare do

  [
    [IssuesController, RedmineRequiredField::Patches::IssuesControllerPatch]
  ].each do |classname, modulename|
    unless classname.included_modules.include?(modulename)
      classname.send(:include, modulename)
    end
  end

end

