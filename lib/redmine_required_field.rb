
module RedmineRequiredField

  PLUGIN_NAME = 'redmine_required_field'.freeze
  ISSUE_REQUIRED = 'issue_required'.freeze

  ISSUE_STATUS_CLOSED_MARK = ' (*)'.freeze
  ISSUE_STATUS_OPTION_NAME_TEMPLATE = '%s%s'.freeze

  PROJECT_IDS = 'project_ids'.freeze
  TRACKER_IDS = 'tracker_ids'.freeze
  ISSUE_STATUS_IDS = 'issue_status_ids'.freeze


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

end

