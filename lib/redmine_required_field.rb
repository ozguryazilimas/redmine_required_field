
require 'redmine_required_field/hooks/views_issues_hook'


module RedmineRequiredField

  PLUGIN_NAME = 'redmine_required_field'.freeze
  ISSUE_REQUIRED = 'issue_required'.freeze

  ISSUE_STATUS_CLOSED_MARK = ' (*)'.freeze
  ISSUE_STATUS_OPTION_NAME_TEMPLATE = '%s%s'.freeze

  PROJECT_IDS = 'project_ids'.freeze
  TRACKER_IDS = 'tracker_ids'.freeze
  ISSUE_STATUS_IDS = 'issue_status_ids'.freeze
  ROLE_IDS = 'role_ids'.freeze
  SETTINGS = 'rrf_settings'.freeze
  ROLE_EXCLUDED = 'role_excluded'.freeze
  CHECK_ASSIGNEE_ONLY = 'check_assignee_only'.freeze

  def self.settings
    HashWithIndifferentAccess.new(Setting[:plugin_redmine_required_field])
  end

  def self.settings_issue_required
    raw_settings = settings[ISSUE_REQUIRED.to_sym]
    raw_settings = JSON.parse(raw_settings) if raw_settings.is_a?(String)
    raw_settings
  rescue => e
    []
  end

  def self.settings_issue_required_for_project(project)
    return [] if project.blank?

    project_id = project.is_a?(Project) ? project.id : project.to_i

    matched = settings_issue_required.select do |setting|
      setting_project_ids = setting[PROJECT_IDS]

      setting_project_ids.blank? ||
        setting_values_match_id(setting_project_ids, project_id)
    end

    matched.presence || []
  end

  def self.related_issue_status_options
    IssueStatus.sorted.pluck(:name, :is_closed, :id).map do |raw_name, is_closed, id|
      extra_char = is_closed ? ISSUE_STATUS_CLOSED_MARK : nil
      name = format(ISSUE_STATUS_OPTION_NAME_TEMPLATE,  raw_name, extra_char)

      [name, id]
    end
  end

  def self.related_project_options
    Project.active.order(:name).pluck(:name, :id)
  end

  def self.related_tracker_options
    Tracker.sorted.pluck(:name, :id)
  end

  def self.related_roles
    Role.sorted.pluck(:name, :id)
  end

  def self.setting_values_match_id(rrf_setting, value)
    return true if rrf_setting.blank?
    # not for ids, but may need to enable for other attribute types
    # return true if value.blank?

    rrf_setting.map(&:to_i).include?(value.to_i)
  end

  def self.current_roles
    # postgresql complains order by is not in select if we fetch roles through user association
    Role.where(:id => User.current.roles).sorted.pluck(:name,:id)
  end

  def self.setting_values_contain_ids(rrf_setting, arr)
    return true if rrf_setting.blank?

    # not for ids, but may need to enable for other attribute types
    # return true if value.blank?
    idary = arr.map{|k| k[1]}
    (rrf_setting.map(&:to_i) & idary).any?
  end

end

