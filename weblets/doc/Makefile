#*=====================================================================*/
#*    serrano/prgm/project/hop/2.2.x/weblets/doc/Makefile              */
#*    -------------------------------------------------------------    */
#*    Author      :  Manuel Serrano                                    */
#*    Creation    :  Fri Jan 20 14:35:57 2006                          */
#*    Last change :  Fri Dec 10 08:20:46 2010 (serrano)                */
#*    Copyright   :  2006-10 Manuel Serrano                            */
#*    -------------------------------------------------------------    */
#*    The Makefile of the DOC weblet                                   */
#*=====================================================================*/

#*---------------------------------------------------------------------*/
#*    CONFIG ...                                                       */
#*---------------------------------------------------------------------*/
TITLE = doc
VERSION = 1.1.0
MINHOP = $(HOPRELEASE) 
MAXHOP =
CATEGORY = hop
DATE = $(HOPDATE)

#*---------------------------------------------------------------------*/
#*    Population                                                       */
#*---------------------------------------------------------------------*/
SOURCES         = doc.hop config.hop doc.scm \
                  api.hop tutorials.hop libraries.hop weblets.hop \
                  search.hop widgets.hop wiki.hop services.hop index.hop
API_POP		= access.wiki base64.wiki cache.wiki cgi.wiki config.wiki \
                  cookie.wiki delay.wiki dom.wiki editor.wiki exception.wiki \
                  fileselect.wiki filters.wiki foldlist.wiki head.wiki \
                  hooks.wiki hss.wiki html.wiki http-message.wiki \
                  http-request.wiki http-response.wiki http.wiki \
                  img.wiki input.wiki inline.wiki md5.wiki sha1.wiki aes.wiki \
                  notepad.wiki pan.wiki param-misc.wiki \
                  param-rc.wiki parameter.wiki \
                  read.wiki service.wiki slider.wiki sorttable.wiki \
                  sqlite.wiki multimedia.wiki tabslider.wiki \
                  timeout.wiki tree.wiki url.wiki wiki.wiki \
                  window.wiki xml.wiki symbol.wiki rss.wiki history.wiki \
                  regexp.wiki output.wiki webdav.wiki \
                  charset.wiki svg.wiki mathml.wiki canvas.wiki login.wiki \
                  condexpand.wiki lframe.wiki spinbutton.wiki gauge.wiki \
                  colorchooser.wiki font.wiki javascript.wiki \
                  audio.wiki video.wiki spage.wiki
CORE_POP	= core.wiki
JS_POP		= js-interface.wiki
EXAMPLES_POP	= base64.hop editor-form.hop editor.hop \
                  canvas.hop canvas2.hop canvas3.hop canvas4.hop canvas5.hop \
                  filebrowse.hop filebrowse2.hop \
                  filebrowse3.hop filebrowse4.hop\
                  filter-1.hop filter-2.hop \
                  foldlist-1.hop foldlist-2.hop hook-1.hop inline.hop \
                  iwindow.hop notepad-1.hop notepad-2.hop notepad-3.hop \
                  paned-1.hop paned-2.hop parameter.hop request-1.hop rss.hop \
                  service-2.hop service-3.hop service-4.hop \
                  service-5.hop service-6.hop slider-1.hop slider-2.hop \
                  sorttable.hop tabslider-1.hop tabslider-2.hop \
                  tree-1.hop tree-2.hop \
                  prefs-1.hop \
                  wiki.hop wiki2.hop window.hop history-1.hop history-2.hop \
                  cookie.hop webdav.hop svg.hop svg2.hop svg3.hop mathml.hop \
                  login.hop json.hop busyanim.hop musicplay.hop form.hop \
                  lframe.hop spinbutton.hop colorchooser.hop S3.hop \
                  audio-server.hop audio-browser-1.hop audio-browser-2.hop \
                  video.hop videoenc.hop gauge.hop beers.hop \
                  spage.hop
WEBLETS_POP	= .keep
WIKI_POP	= basic.wiki hop.wiki link.wiki lists.wiki misc.wiki \
                  paragraph.wiki plugin.wiki section.wiki syntax.wiki \
                  tables.wiki tt.wiki image.wiki quote.wiki include.wiki \
                  math.wiki
TUTORIAL_POP	= 00-hello.wiki 01-ajax.wiki 02-hss.wiki 03-proxy.wiki \
		  04-authentication.wiki 05-rss.wiki 06-hz.wiki \
                  07-hoprc.wiki 08-history.wiki 09-resource.wiki \
                  11-rest.wiki

POPULATION	= Makefile doc.hss doc.scm \
                  examples api core wiki tutorials etc/weblet.info.in \
                  etc/logo.png etc/doc.wiki.in \
                  etc/sound1.mp3 etc/sound2.mp3 \
                  etc/kangaroo.svgz \
                  etc/favicon.png \
                  etc/anim.gif \
                  $(SOURCES) \
		  $(API_POP:%=api/%) \
		  $(CORE_POP:%=core/%) \
		  $(JS_POP:%=js/%) \
		  $(EXAMPLES_POP:%=examples/%) \
		  $(WEBLETS_POP:%=weblets/%) \
		  $(WIKI_POP:%=wiki/%) \
		  $(TUTORIAL_POP:%=tutorials/%)

build: etc/weblet.info etc/$(TITLE).wiki .afile

clean:

distclean:
	$(RM) etc/weblet.info etc/$(TITLE).wiki

#*---------------------------------------------------------------------*/
#*    Configuration                                                    */
#*---------------------------------------------------------------------*/
-include ../../etc/Makefile.hopconfig
-include ../../etc/Makefile.version

#*---------------------------------------------------------------------*/
#*    Dependencies                                                     */
#*---------------------------------------------------------------------*/
etc/weblet.info: etc/weblet.info.in Makefile
	cat $< | sed -e "s|@HZ@|$(HZ)|" \
                     -e "s|@TITLE@|$(TITLE)|" \
                     -e "s|@VERSION@|$(VERSION)|" \
                     -e "s|@MINHOP@|$(MINHOP)|" \
                     -e "s|@MAXHOP@|$(MAXHOP)|" \
                     -e "s|@PUBLISHER@|$(PUBLISHER)|" \
                     -e "s|@DATE@|$(DATE)|" \
                     -e "s|@PRIVATEHOST@|$(PRIVATEHOST)|" \
                     -e "s|@PUBLICHOST@|$(PUBLICKHOST)|" \
                     -e "s|@CATEGORY@|$(CATEGORY)|" > $@

%.wiki: %.wiki.in Makefile
	cat $< | sed -e "s|@VERSION@|$(VERSION)|" \
                     -e "s|@MINHOP@|$(MINHOP)|" \
                     -e "s|@HZ@|$(HZ)|" \
                     -e "s|@MAXHOP@|$(MAXHOP)|" \
                     -e "s|@HOST@|$(PRIVATEHOST)|" \
                     -e "s|@DATE@|$(DATE)|" \
                     -e "s|@PUBLISHER@|$(PUBLISHER)|" \
                     -e "s|@TITLE@|$(TITLE)|" \
                     -e "s|@CATEGORY@|$(CATEGORY)|" > $@

config.hop: config.hop.in Makefile
	cat $< | sed -e "s|@VERSION@|$(VERSION)|" \
                     -e "s|@HOPRELEASE@|$(HOPRELEASE)|" \
                     -e "s|@TITLE@|$(TITLE)|" \
                     -e "s|@MINHOP@|$(MINHOP)|" \
                     -e "s|@DATE@|$(DATE)|" \
                     -e "s|@HOST@|$(PRIVATEHOST)|" \
                     -e "s|@CATEGORY@|$(CATEGORY)|" > $@

.afile: $(SOURCES)
	$(AFILE) -suffix hop $(SOURCES) -o .afile

