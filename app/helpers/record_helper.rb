# encoding: UTF-8
module RecordHelper
  def display_content_field(field)
    return unless field.respond_to?(:label, :values) && field.values.any?(&:present?)

    display_content_label(field.label) + display_content_values(field.values)
  end

  def display_content_label(label)
    content_tag :dt, label
  end

  def display_content_values(values)
    values.map do |value|
      content_tag :dd, value
    end.join('').html_safe
  end

  def mods_display_label(label)
    content_tag(:dt, label.delete(':'))
  end

  def mods_display_content(values, delimiter = nil)
    if delimiter
      content_tag(:dd, values.map do|value|
        link_urls_and_email(value) if value.present?
      end.compact.join(delimiter).html_safe)
    else
      Array[values].flatten.map do |value|
        content_tag(:dd, link_urls_and_email(value.to_s).html_safe) if value.present?
      end.join.html_safe
    end
  end

  def mods_record_field(field, delimiter = nil)
    return unless field.respond_to?(:label, :values) && field.values.any?(&:present?)
    mods_display_label(field.label) + mods_display_content(field.values, delimiter)
  end

  def mods_name_field(field)
    return unless field.respond_to?(:label, :values) && field.values.any?(&:present?)
    mods_display_label(field.label) + mods_display_name(field.values)
  end

  def mods_display_name(names)
    names.map do |name|
      content_tag(:dd) do
        name.name + ((" (#{name.roles.join(', ')})" if name.roles) || '')
      end
    end.join.html_safe
  end

  def mods_subject_field(subjects)
    fields = subjects.values.map do |subject_line|
      content_tag :dd, link_mods_subjects(subject_line).join(' > ')
    end

    mods_display_label(subjects.label) + safe_join(fields, "\n")
  end

  def mods_genre_field(genres)
    fields = genres.values.map do |genre_line|
      content_tag :dd, link_mods_genres(genre_line)
    end

    mods_display_label(genres.label) + safe_join(fields, "\n")
  end

  def link_mods_genres(genre)
    link_buffer = []
    link_to_mods_subject(genre, link_buffer)
  end

  def link_mods_subjects(subjects)
    link_buffer = []
    linked_subjects = []
    subjects.each do |subject|
      if subject.present?
        linked_subjects << link_to_mods_subject(subject, link_buffer)
      end
    end
    linked_subjects
  end

  def link_to_mods_subject(subject, buffer)
    subject_text = subject.respond_to?(:name) ? subject.name : subject
    link = subject_text
    buffer << subject_text.strip
    link << " (#{subject.roles.join(', ')})" if subject.respond_to?(:roles) && subject.roles.present?
    link
  end

  # rubocop:disable Metrics/LineLength
  def link_urls_and_email(val)
    val = val.dup
    # http://daringfireball.net/2010/07/improved_regex_for_matching_urls
    url = %r{(?i)\b(?:https?://|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\([^\s()<>]+|\([^\s()<>]+\)*\))+(?:\([^\s()<>]+|\([^\s()<>]+\)*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’])}i
    # http://www.regular-expressions.info/email.html
    email = %r{[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)\b}i
    matches = [val.scan(url), val.scan(email)].flatten.uniq
    unless val =~ /<a/ # we'll assume that linking has alraedy occured and we don't want to double link
      matches.each do |match|
        if match =~ email
          val.gsub!(match, "<a href='mailto:#{match}'>#{match}</a>")
        else
          val.gsub!(match, "<a href='#{match}'>#{match}</a>")
        end
      end
    end
    val
  end
  # rubocop:enable Metrics/LineLength
end
