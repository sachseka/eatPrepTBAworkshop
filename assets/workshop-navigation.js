/* Chapter links and a local slide count, including the exported PDF. */
(() => {
  'use strict';

  function initializeNavigation() {
    const deck = window.Reveal;
    const root = deck.getRevealElement();
    if (root.querySelector(':scope > .workshop-navigation')) return;

    const slides = deck.getSlides();
    const shortLabels = {
      '1': '1 Paket & Datenabruf',
      '2': '2 Aufbereitung & Kodierung',
      '3': '3 Logdaten',
      '4': '4 Codebücher'
    };
    const chapters = slides.filter(slide => slide.classList.contains('chapter'))
      .map((slide, index) => {
        const title = slide.querySelector('h2')?.textContent.trim() || '';
        const number = title.match(/^\d+/)?.[0] || String(index + 1);
        return {slide, title, key: number,
          label: slide.dataset.navLabel || shortLabels[number] || title};
      });
    const chapterBySlide = new Map(chapters.map(chapter => [chapter.slide, chapter]));
    const groups = new Map();
    const positions = new Map();
    let current = {key: 'entry', label: 'Einstieg'};

    slides.forEach(slide => {
      if (chapterBySlide.has(slide)) current = chapterBySlide.get(slide);
      const heading = slide.querySelector('h2')?.textContent.trim();
      if (slide.classList.contains('workshop-end') || heading === 'Auf eigene Daten übertragen') {
        current = {key: 'end', label: 'Abschluss'};
      }
      if (!groups.has(current.key)) groups.set(current.key, []);
      const group = groups.get(current.key);
      group.push(slide);
      positions.set(slide, {group: current, position: group.length});
    });

    function makeNavigation(slide, forPrint = false) {
      const position = positions.get(slide);
      if (!position) return null;
      const total = groups.get(position.group.key).length;
      const nav = document.createElement('nav');
      nav.className = 'workshop-navigation' + (forPrint ? ' workshop-navigation-print' : '');
      nav.setAttribute('aria-label', 'Workshopabschnitte');
      nav.dataset.section = position.group.key;
      nav.dataset.position = position.position;
      nav.dataset.total = total;

      const links = document.createElement('div');
      links.className = 'workshop-navigation-links';
      chapters.forEach(chapter => {
        const link = document.createElement('a');
        link.textContent = chapter.label;
        link.href = '#/' + chapter.slide.id;
        link.title = chapter.title;
        link.dataset.section = chapter.key;
        if (chapter.key === position.group.key) link.setAttribute('aria-current', 'step');
        if (!forPrint) {
          link.addEventListener('click', event => {
            event.preventDefault();
            const indices = deck.getIndices(chapter.slide);
            deck.slide(indices.h, indices.v);
          });
        }
        links.append(link);
      });

      const progress = document.createElement('span');
      progress.className = 'workshop-navigation-progress';
      const isChapter = chapterBySlide.has(position.group.slide);
      progress.textContent = isChapter
        ? `Folie ${position.position}/${total} im Abschnitt`
        : `${position.group.label} · Folie ${position.position}/${total}`;
      nav.append(links, progress);
      return nav;
    }

    function updateNavigation() {
      const nav = makeNavigation(deck.getCurrentSlide());
      if (!nav) return;
      root.querySelector(':scope > .workshop-navigation')?.remove();
      root.append(nav);
    }

    function addPrintNavigation() {
      root.querySelectorAll('.pdf-page').forEach(page => {
        if (page.querySelector(':scope > .workshop-navigation-print')) return;
        const slide = page.querySelector('section.slide');
        const nav = makeNavigation(slide, true);
        if (nav) page.append(nav);
      });
    }

    updateNavigation();
    addPrintNavigation();
    deck.on('slidechanged', updateNavigation);
    deck.on('pdf-ready', addPrintNavigation);
  }

  function start() {
    if (!window.Reveal) return;
    if (window.Reveal.isReady()) initializeNavigation();
    else window.Reveal.on('ready', initializeNavigation);
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start);
  else start();
})();
