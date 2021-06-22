class Supporter
  attr_reader :name, :url, :logo_name

  ALL = [
    ['Paul Kolarik', 'https://kolarik.at', 'kolarik.png'],
    ['Elif Lisa Hakçobani', 'https://www.geldmachtwas.com', 'elif-macht-was.png'],
    ['WIENER BEZIRKSIMKEREI', 'https://www.wiener-bezirksimkerei.at', 'bezirksimkerei.png'],
    ['CAROLINE CERMAK / LIEBESRAUM 2.0', 'https://liebesraum2.com', 'cermak.png'],
    ['ELISABETH MOLZBICHLER / BUSINESS MOMS AUSTRIA', 'https://www.businessmoms.at', 'business-moms.jpg'],
    ['PAMELA-RANI GINDL / RANI YOGA', 'http://www.rani-yoga.at', 'rani-yoga.jpg'],
    ['CORONA GSTEU', 'https://www.coronagsteu.com', 'corona-gsteu.jpg'],
    ['ELISABETH HUNDSTORFER / DER ACHTE', 'http://derachte.at', 'der-achte.jpg'],
    ['ROSA DIRMHIRN', 'http://www.dirmhirn.at', 'dirmhirn.png'],
    ['ELISABETH WALTER / DIE AUFSTELLERIN', 'http://www.elisabethwalter.com', 'elisabeth-walter.png'],
    ['THOMAS MANHARTSBERGER', 'https://www.manhartsberger.at', 'manhartsberger.png'],
    ['GABI WALCHHÜTTER / HEALTH CONSULT', 'https://www.health-consult.at', 'healthconsult.png'],
    ['ANGELIKA POHNITZER', 'http://the.way.foturis.works', 'pohnitzer.png'],
    ['ASTRID EDLINGER', 'https://raumen.at', 'raumen.png'],
    ['SILVIA FORLATI - SHARE ARCHITECTS', 'https://www.instagram.com/share_architects', 'share-architects.png'],
    ['BARBARA KAINZ / KINDERBERATUNG', 'https://www.kinder-beratung.at', 'kainz.jpg'],
    ['CHRISTINE SCHRENK', 'https://www.aura-klang.at', 'schrenk.jpg'],
    ['MARIE MEYER-MARKTL / FULFILMENT AT WORK', 'http://www.fulfilment-at-work.at', 'marie-meyer-marktl.jpg'],
    ['DRAZEN LUCANIN / PUNKROCKDEV', 'https://punkrockdev.com', 'punkrockdev.png'],
    ['PETER SITTLER / SITTLER CONSULTING', 'http://www.sittler.at', 'sittler.png'],
    ['KATHARINA UND WOLFGANG / FATTO-DA-K', 'https://www.fatto-da-k.at', 'baumann.jpg'],
  ]

  def self.random(n)
    ALL.sample(n).map{ |attrs| new(*attrs) }
  end

  def initialize(name, url, logo_name)
    @name, @url, @logo_name = name, url, logo_name
  end

end