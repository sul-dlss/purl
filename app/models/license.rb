class License
  include ActiveModel::Model
  attr_accessor :code, :text

  def desc
    LICENSES.fetch(code, {})[:desc] || text
  end

  def link
    LICENSES.fetch(code, {})[:link]
  end

  LICENSES = {
    'creativeCommons-none' => { desc: '' },
    'creativeCommons-by' => {
      link: 'http://creativecommons.org/licenses/by/3.0/',
      desc: 'This work is licensed under a Creative Commons Attribution 3.0 Unported License'
    },
    'creativeCommons-by-sa' => {
      link: 'http://creativecommons.org/licenses/by-sa/3.0/',
      desc: 'This work is licensed under a Creative Commons Attribution-Share Alike 3.0 Unported License'
    },
    'creativeCommons-by-nd' => {
      link: 'http://creativecommons.org/licenses/by-nd/3.0/',
      desc: 'This work is licensed under a Creative Commons Attribution-No Derivative Works 3.0 Unported License'
    },
    'creativeCommons-by-nc' => {
      link: 'http://creativecommons.org/licenses/by-nc/3.0/',
      desc: 'This work is licensed under a Creative Commons Attribution-Noncommercial 3.0 Unported License'
    },
    'creativeCommons-by-nc-sa' => {
      link: 'http://creativecommons.org/licenses/by-nc-sa/3.0/',
      desc: 'This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 3.0 Unported License'
    },
    'creativeCommons-by-nc-nd' => {
      link: 'http://creativecommons.org/licenses/by-nc-nd/3.0/',
      desc: 'This work is licensed under a Creative Commons Attribution-Noncommercial-No Derivative Works 3.0 Unported License'
    },
    'creativeCommons-pdm' => {
      link: 'http://creativecommons.org/publicdomain/mark/1.0/',
      desc: 'This work is in the public domain per Creative Commons Public Domain Mark 1.0'
    },
    'openDataCommons-odc-pddl' => {
      link: 'http://opendatacommons.org/licenses/pddl/',
      desc: 'This work is licensed under a Open Data Commons Public Domain Dedication and License (PDDL)'
    },
    'openDataCommons-pddl' => {
      link: 'http://opendatacommons.org/licenses/pddl/',
      desc: 'This work is licensed under a Open Data Commons Public Domain Dedication and License (PDDL)'
    },
    'openDataCommons-odc-by' => {
      link: 'http://opendatacommons.org/licenses/by/',
      desc: 'This work is licensed under a Open Data Commons Attribution License'
    },
    'openDataCommons-odc-odbl' => {
      link: 'http://opendatacommons.org/licenses/odbl/',
      desc: 'This work is licensed under a Open Data Commons Open Database License (ODbL)'
    }
  }
end
