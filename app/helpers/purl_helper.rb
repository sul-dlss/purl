
module PurlHelper

  def round_to(num,decimals=0)
    factor = 10.0**decimals
    (num*factor).round / factor
  end
  
end
