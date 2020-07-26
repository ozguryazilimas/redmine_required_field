
# Redmine Required Field

Allows forcing users to fill spent time fields during updating issues. During issue update
if issue status is one of the statuses configured in the plugin settings, spent time field
is marked as required. On changing issue form fields spent time is marked as required dynamically.


## Configuration

An administrator user can go to Administration Plugin Settings page of Redmine for Redmine Required Field.
On this page you can add or remove issue matches. Each matcher can define multiple of Projects, Issue
Statuses and Trackers. If one of those fields is empty, it means "all of them". An issue matching
any one of these fields will be considered to have spent time as required.

Note you can select / deselect inside the multiselect views by holding CTRL key and clicking on the option
in select.

Once you configure a matcher, you click "Add" which adds it to the existing configuration. At this point
your configuration is not saved yet, you need to click Update at the bottom to update Redmine configuration.


## License

Copyright (c) 2020 Onur Küçük. Licensed under [GNU GPLv2](LICENSE)

