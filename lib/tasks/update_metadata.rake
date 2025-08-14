task update_metadata: :environment do
  druids = [
    'bb000br0025', # Not crawlable
    'bb157hs6068', # has extent in the metadata
    'bb737zp0787', # book, world access, with OCR
    'bd786fy6312', # media
    'bf385jz2076', # book, no-download, with OCR
    'bf973rp9392', # released to searchworks
    'bf995rh7184', # book, stanford-only, with OCR
    'bg387kw8222', # 3d object
    'bh502xm3351', # document (pdf)
    'cd027gx5097', # item that is part of collection (ss099gb5528) not released to searchworks
    'cg357zz0321', # geo object
    'cg767mn6478', # image, world, covers to atlas
    'cp088pb1682', # image released to searchworks that is a member of a collection (sk882gx0113)
    'cz128vq0535', # geo (TODO: consolication target?)
    'gk894yk3598', # collection without a FOLIO hrid
    'gx074xz5520', # file type that is part of a collection (yb533nc1884)
    'hc941fm6529', # 3d object (TODO: consolication target?)
    'hj097bm8879', # a parent object
    # 'hx163dc5225', # has annotations - can't be updated yet
    'jg072yr3056', # book, world access, with OCR (TODO: consolidate with bb737zp0787?)
    'jw923xn5254', # second child object
    'nd387jf5675', # ETD
    'py305sy7961', # map, world access
    'qf794pv6287', # 3d object (TODO: consolication target?)
    'rf433wv2584', # image where jp2 is not downloadable
    # 'rp193xx6845', # map, world access, has coordinates in the metadata (TODO:consolidate with py305sy7961?) - can't be updated yet
    'rs276tc2764', # grandfathered namespace
    'sk882gx0113', # a collection released to searchworks with a member (cp088pb1682)
    'ss099gb5528', # a collection not released to searchworks with a member (cd027gx5097)
    'wm135gp2721', # file, world access, has an ORCiD
    'wy534zh7137', # the rosette jpg
    'xm166kd3734', # TODO: consolidate
    'yb533nc1884', # collection with member (gx074xz5520)
    # 'yk677wc8843', # file, stanford-only OCLC link - can't be updated
    'yr183sf1341', # book, world access, right-to-left
    # 'yy816tv6021', # media, location access - can't be updated yet
    'zb733jx3137', # an item with 4 versions
    'zb871zd0767', # collection
    'zf119tw4418' # book, world access, with OCR (TODO: consolidate with bb737zp0787?)
  ]
  druids.each do |druid|
    tree = Dor::Util.create_pair_tree(druid)
    FileUtils.rm_f("spec/fixtures/document_cache/#{tree}")
    dest = "spec/fixtures/document_cache/#{tree}/#{druid}"
    src = "/stacks/#{tree}/#{druid}/versions"

    FileUtils.mkdir_p(dest)
    `scp -r lyberadmin@purl-fetcher-prod:#{src} #{dest}`
  end
end
