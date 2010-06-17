# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # To convert bytes to Kilobytes
  def bytesToKB(bytes)
    kilo_bytes = bytes
    # if size > 1K, convert to Kilobytes
    if bytes > 1024
      kilo_bytes = ((bytes/1024).ceil).to_s + 'K'
    end
    return kilo_bytes.to_s
  end

  # To convert UTC timestamp to formatted PST timestamp
  def convertTimestamp(timestamp) 
    timeUTC = Time.parse(timestamp)
    timePST = timeUTC.localtime
    return timePST.strftime("%d-%b-%Y %I:%M %p")
  end

  # To format PST timestamp
  def formatTimestampPST(timestamp) 
    timePST = Time.parse(timestamp)
    return timePST.strftime("%d-%b-%Y %I:%M %p")
  end

  # To format PST timestamp
  def getUserFriendlyTimestamp(timestamp)
    timePST = Time.parse(timestamp)
    return timePST.strftime("%d-%b-%Y %I:%M %p")
  end

  # Format submission data timestamp 
  def formatTimestamp(timestamp)
    if timestamp =~ /^\d{10}$/  
      timePST = Time.at(timestamp.to_i).to_s
      return getUserFriendlyTimestamp(timePST)
    elsif timestamp =~ /\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}/
      return getUserFriendlyTimestamp(timestamp)
    else 
      return timestamp
    end 
  end

  # Advance date by given time
  # (e.g. 2 days, 2d, 3 month, 3m, 1 year, 1y)
  def advanceDate(timestamp, timeToAdd)
    newTime = timestamp
    advanceBy = {}

    if (timeToAdd =~ /(\d+)\s*d(ay)?/i)
       advanceBy = {:days => $1.to_i}
    elsif (timeToAdd =~ /(\d+)\s*m(onth)?/i)
       advanceBy = {:months => $1.to_i}
    elsif (timeToAdd =~ /(\d+)\s*y(ear)?/i)
       advanceBy = {:years => $1.to_i}
    end 
  
    newTime = Time.parse(timestamp).advance(advanceBy)
    return newTime.strftime("%d-%b-%Y")
  end

  # Get file extension
  def fileExtension(filename)
    extension = File.extname(filename).upcase
    extension = extension.gsub /\./, ''
    return extension
  end

  # Format 'lastname, firstname' to 'firstname lastname'
  def formatName(name) 
    if name =~ /(.*?),(.*)/ 
      name = $2 + ' ' + $1
    end 

    return name
  end

  # Get purl 
  def getPurl(druid) 
    druid = druid.gsub /^druid\:/, ''
    purl = 'http://purl.stanford.edu/' + druid
    return purl
  end

  # Format abstract text - add paragraph breaks
  def formatAbstract(text) 
    text = text.to_s.gsub!(/[\n\r]+/, '</p><p>')

    if text.to_s.length > 0 
      text = '<p>' + text.to_s + '</p>'
    end 

    return text.to_s
  end

  # EscapeTage - escape < & > for HTML display
  def escapeTags(value)
    value = value.gsub(/</, '&lt;')
    value = value.gsub(/>/, '&gt;')
    return value
  end 

  # Get file icon for a filename
  def fileIcon(filename) 
    fileIcons = { 
      "aif" => "audio_32x.png", 
      "asf" => "video_32x.png", 
      "asp" => "text_32x.png", 
      "asx" => "video_32x.png", 
      "au" => "audio_32x.png", 
      "avi" => "video_32x.png", 
      "bz" => "zip_32x.png", 
      "bz2" => "zip_32x.png", 
      "c" => "c_32x.png", 
      "class" => "java_32x.png", 
      "conf" => "text_32x.png", 
      "cpp" => "cpp_32x.png", 
      "csh" => "script_32x.png", 
      "css" => "css_32x.png", 
      "doc" => "word_32x.png", 
      "docx" => "word_32x.png", 
      "f" => "f_32x.png", 
      "gif" => "image_32x.png", 
      "gz" => "gzip_32x.png", 
      "gzip" => "gzip_32x.png", 
      "h" => "h_32x.png", 
      "help" => "help_32x.png", 
      "hlp" => "help_32x.png", 
      "htm" => "web_32x.png", 
      "html" => "web_32x.png", 
      "i" => "i_32x.png", 
      "j" => "j_32x.png", 
      "jar" => "jar_32x.png", 
      "java" => "java_32x.png", 
      "jpe" => "image_32x.png", 
      "jpeg" => "image_32x.png", 
      "jpg" => "image_32x.png", 
      "js" => "source_32x.png", 
      "ksh" => "script_32x.png", 
      "latex" => "tex_32x.png", 
      "log" => "log_32x.png", 
      "m" => "text_32x.png", 
      "m3u" => "audio_32x.png", 
      "make" => "make_32x.png", 
      "mid" => "audio_32x.png", 
      "midi" => "audio_32x.png", 
      "mod" => "audio_32x.png", 
      "mov" => "quicktime_32x.png", 
      "mp2" => "video_32x.png", 
      "mp3" => "audio_32x.png", 
      "mpeg" => "video_32x.png", 
      "mpg" => "video_32x.png", 
      "o" => "o_32x.png", 
      "p" => "p_32x.png", 
      "pdf" => "pdf_32x.png", 
      "php" => "php_32x.png", 
      "pict" => "image_32x.png", 
      "pl" => "perl_32x.png", 
      "pm" => "source_32x.png", 
      "png" => "image_32x.png", 
      "pps" => "ppt_32x.png", 
      "ppt" => "ppt_32x.png", 
      "pptx" => "ppt_32x.png", 
      "psd" => "image_32x.png", 
      "py" => "py_32x.png", 
      "ra" => "audio_32x.png", 
      "ram" => "audio_32x.png", 
      "rtf" => "text_32x.png", 
      "s" => "s_32x.png", 
      "sh" => "script_32x.png", 
      "shtml" => "web_32x.png", 
      "sid" => "audio_32x.png", 
      "tar" => "zip_32x.png", 
      "tcl" => "script_32x.png", 
      "tcsh" => "script_32x.png", 
      "tex" => "tex_32x.png", 
      "text" => "text_32x.png", 
      "tgz" => "gzip_32x.png", 
      "tif" => "image_32x.png", 
      "tiff" => "image_32x.png", 
      "tpl" => "tpl_32x.png", 
      "txt" => "text_32x.png", 
      "xla" => "spreadsheet_32x.png", 
      "xlb" => "spreadsheet_32x.png", 
      "xlc" => "spreadsheet_32x.png", 
      "xld" => "spreadsheet_32x.png", 
      "xlk" => "spreadsheet_32x.png", 
      "xll" => "spreadsheet_32x.png", 
      "xlm" => "spreadsheet_32x.png", 
      "xls" => "spreadsheet_32x.png", 
      "xlsx" => "spreadsheet_32x.png", 
      "xlt" => "spreadsheet_32x.png", 
      "xlv" => "spreadsheet_32x.png", 
      "xlw" => "spreadsheet_32x.png", 
      "y" => "y_32x.png", 
      "z" => "zip_32x.png", 
      "zip" => "zip_32x.png", 
      "zsh" => "script_32x.png" 
    }

    fileIcons.default = "unknown_32x.png"
    ext = fileExtension(filename).downcase
 
    return fileIcons[ext] 

  end

end
