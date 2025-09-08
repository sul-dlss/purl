# frozen_string_literal: true

FIXTURES = [
  'bb000qr5025', # image where jp2 is not downloadable
  'bb001dq8600', # image, stanford-only
  'bb157hs6068', # map, world acccess, has extent in the metadata, member of collection (zb871zd0767), has HRID (10624936), not crawlable
  'bb253gh8060', # file, stanford-only
  'bb737zp0787', # book, world access, with OCR
  'bc854fy5899', # book, world access, without OCR
  'bd699ky6829', # media, world access, with vtt
  'bd786fy6312', # media
  'bf385jz2076', # book, no-download, with OCR
  'bf973rp9392', # image, released to searchworks
  'bf995rh7184', # book, stanford-only, with OCR
  'bg387kw8222', # 3d object
  'cd027gx5097', # item that is part of collection (ss099gb5528) not released to searchworks
  'cg357zz0321', # geo object
  'cg767mn6478', # image, world, covers to atlas
  'cp088pb1682', # image released to searchworks that is a member of a collection (sk882gx0113)
  'fj935vg7746', # media type, with ISO disk-image. (possibly incorrect content type)
  'gk894yk3598', # collection without a FOLIO hrid
  'gx074xz5520', # file type that is part of a collection (yb533nc1884)
  'hj097bm8879', # a parent object
  'hx163dc5225', # has annotations
  'jw923xn5254', # second child object
  'nd387jf5675', # ETD
  'rp193xx6845', # map, world access, has coordinates in the metadata
  'rs276tc2764', # file, world access, a dataset, grandfathered ir: namespace
  'rx923hn2102', # book, location specific, files download none
  'sk882gx0113', # a collection released to searchworks with a member (cp088pb1682)
  'ss099gb5528', # a collection not released to searchworks with a member (cd027gx5097)
  'tb420df0840', # image, location restricted
  'wm135gp2721', # file, world access, dataset, has an ORCiD and DOI
  'xq467yj8428', # document, stanford-only
  'yb533nc1884', # collection with member (gx074xz5520)
  'yr183sf1341', # book, world access, without OCR, right-to-left
  'yy816tv6021', # media, location access
  'zb733jx3137', # file, world access, has 4 versions
  'zb871zd0767', # collection (that contains bb157hs6068)
  'zf119tw4418', # book, world access, without OCR (OCR exists, but it not published/shelved), resources are images (old style?)
  'zm796xp7877' # book, with first page dark
].freeze

task update_metadata: :environment do
  FIXTURES.each do |druid|
    tree = Dor::Util.create_pair_tree(druid)
    FileUtils.rm_f("#{Settings.stacks.root}/#{tree}")
    dest = "#{Settings.stacks.root}/#{tree}/#{druid}"
    src = "/stacks/#{tree}/#{druid}/versions"

    FileUtils.mkdir_p(dest)
    `scp -r lyberadmin@purl-fetcher-prod:#{src} #{dest}`
  end
end
