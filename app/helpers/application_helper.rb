# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def formatted_date(time, options = {})
    formatted_datetime(time, "%b %d, %Y", options)
  end
  
  def formatted_time(time, options = {})
    formatted_datetime(time, "%b %d, %Y at %I:%M %p %Z", options)
  end
  
  def formatted_datetime(time, format, options = {})
    options.symbolize_keys!
    options[:force_date] ||= false
    
    if (options[:force_date] == false) && (time < Time.now.utc)
      return time_ago_in_words(time).sub(/about /, '') + " ago"
    else
      t = ""
      t += "#{options[:pretext]} " if options[:pretext]
      t += time.strftime(format)
      t += " #{options[:posttext]}" if options[:posttext]
      return t
    end
  end
  
  def display_flash_message
    flash_types = [:error, :warning, :notice ]
    flash_type = flash_types.detect{ |a| flash.keys.include?(a) }
    
    flash[flash_type] if flash_type
  end
  
  def error_messages_for(*params)
    options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
    objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
    count   = objects.inject(0) {|sum, object| sum + object.errors.count }
    unless count.zero?
      html = {}
      [:id, :class].each do |key|
        if options.include?(key)
          value = options[key]
          html[key] = value unless value.blank?
        else
          html[key] = 'errorExplanation'
        end
      end
      header_message = "Yikes.  This #{(options[:object_name] || params.first).to_s.gsub('_', ' ')} has not been saved!"
      error_messages = objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }
      content_tag(:div,
        content_tag(options[:header_tag] || :h2, header_message) <<
          content_tag(:p, "We found #{pluralize(count, 'error')}:") <<
          content_tag(:ul, error_messages),
        html
      )
    else
      ''
    end
  end
  
  
end
