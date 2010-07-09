
module PurlHelper

  #
  # This method round the given number to the given number of decimal points
  #
  def round_to(num,decimals=0)
    factor = 10.0**decimals
    (num*factor).round / factor
  end

  #
  # This method returns the pair tree directory structure based on the given object identifier.
  # The object identifier must be of the following format, otherwise nil is returned.
  #
  #     druid:xxyyyxxyyyy
  #
  #       where 'x' is an alphabetic character
  #       where 'y' is a numeric character
  #
  def create_pair_tree(pid)
    if(pid =~ /^([a-z]{2})(\d{3})([a-z]{2})(\d{4})$/)
      return File.join($1, $2, $3, $4)
    else
      return nil
    end
  end

end
