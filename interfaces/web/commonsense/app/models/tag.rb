class Tag < ActiveResource::Base
  def link_title
    "#{name.split("#").last.underscore.humanize.titlecase}"
  end
end