;*=====================================================================*/
;*    serrano/prgm/project/hop/2.0.x/widget/paned.scm                  */
;*    -------------------------------------------------------------    */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Thu Aug 18 10:01:02 2005                          */
;*    Last change :  Thu Jun 25 12:06:45 2009 (serrano)                */
;*    Copyright   :  2005-09 Manuel Serrano                            */
;*    -------------------------------------------------------------    */
;*    The HOP implementation of paned.                                 */
;*=====================================================================*/

;*---------------------------------------------------------------------*/
;*    The module                                                       */
;*---------------------------------------------------------------------*/
(module __hopwidget-paned

   (library hop)

   (static  (abstract-class html-paned::xml-element
	       (klass read-only)
	       (fraction read-only)
	       (style read-only (default #f))
	       (height read-only (default #f))
	       (onresize read-only))

	    (class html-vpaned::html-paned)
	    (class html-hpaned::html-paned)

	    (class html-pan::xml-element
	       (klass read-only)))

   (export  (<PANED> . ::obj)
	    (<PAN> . ::obj)))
   
;*---------------------------------------------------------------------*/
;*    <PANED> ...                                                      */
;*    -------------------------------------------------------------    */
;*    See __hop_css for HSS types.                                     */
;*---------------------------------------------------------------------*/
(define-markup <PANED> ((id #unspecified string)
			(class #unspecified string)
			(fraction 0)
			(onresize "")
			(orientation 'vertical)
			(style #f)
			(height #f)
			body)
   (cond
      ((null? body)
       (error '<PANED> "Illegal body, missing two pans" body))
      ((null? (cdr body))
       (error '<PANED> "Illegal body, missing one pan" body))
      ((null? (cddr body))
       (case orientation
	  ((horizontal)
	   (instantiate::html-hpaned
	      (markup 'paned)
	      (id (xml-make-id id 'PANED))
	      (klass class)
	      (fraction fraction)
	      (onresize onresize)
	      (style style)
	      (height height)
	      (body body)))
	  ((vertical)
	   (instantiate::html-vpaned
	      (markup 'paned)
	      (id (xml-make-id id 'PANED))
	      (klass class)
	      (fraction fraction)
	      (onresize onresize)
	      (style style)
	      (height height)
	      (body body)))
	  (else
	   (error '<PANED> "Illegal orientation" orientation))))))

;*---------------------------------------------------------------------*/
;*    <PAN> ...                                                        */
;*---------------------------------------------------------------------*/
(define-markup <PAN> ((id #unspecified string)
		      (class #unspecified string)
		      (attr)
		      body)
   (instantiate::html-pan
      (markup 'PAN)
      (id (xml-make-id id 'PAN))
      (klass class)
      (attributes attr)
      (body body)))

;*---------------------------------------------------------------------*/
;*    xml-write ::html-hpaned ...                                      */
;*---------------------------------------------------------------------*/
(define-method (xml-write obj::html-paned p backend)
   (with-access::html-hpaned obj (id klass fraction onresize body style height)
      (let ((cl (if (string? klass)
		    (string-append "hop-paned hop-hpaned " klass)
		    "hop-paned hop-hpaned")))
	 (fprintf p "<div class='~a' id='~a'" cl id))
      (when style (fprintf p " style='~a'" style))
      (when height (fprintf p " height='~a'" height))
      (display ">" p)
      (xml-write (car body) p backend)
      (fprintf p "<div class='hop-hpaned-cursor' id='~a-hpaned-cursor'></div>" id)
      (xml-write (cadr body) p backend)
      (display " <script type='" p)
      (display (hop-javascript-mime-type) p)
      (display "'>" p)
      (fprintf p
	       "hop_init_hpaned( ~s, ~s, ~s, ~a, function(event) { ~a } )"
	       id (html-pan-id (car body)) (html-pan-id (cadr body))
	       fraction
	       (cond
		  ((xml-tilde? onresize)
		   (xml-tilde->return onresize))
		  ((string? onresize)
		   onresize)
		  (else
		   "")))
      (display " </script></div>" p)))
   
;*---------------------------------------------------------------------*/
;*    xml-write ::html-vpaned ...                                      */
;*---------------------------------------------------------------------*/
(define-method (xml-write obj::html-vpaned p backend)
   (with-access::html-paned obj (id klass fraction onresize body style height)
      (let ((cl (if (string? klass)
		    (string-append "hop-paned " klass)
		    "hop-paned")))
	 (fprintf p "<div class='~a' id='~a'" cl (symbol->string (gensym))))
      (when style (fprintf p " style='~a'" style))
      (when height (fprintf p " height='~a'" height))
      (display ">" p)
      (fprintf p "<table class='hop-vpaned' id='~a' width='100%'>" id)
      (fprint p "<tr>")
      (fprintf p "<td class='hop-vpaned-pan hop-vpaned-pan-left' id='~a-vpaned-td1'>"
	      id)
      (xml-write (car body) p backend)
      (fprint p "</td>")
      (fprintf p "<td class='hop-vpaned-cursor' id='~a-vpaned-cursor'>" id)
      (fprint p "</td>")
      (fprintf p "<td class='hop-vpaned-pan hop-vpaned-pan-right' id='~a-vpaned-td2'>"
	      id)
      (xml-write (cadr body) p backend)
      (fprint p "</td>")
      (fprint p "</tr>")
      (fprint p "</table>")
      (fprintf p "<script type='~a'>" (hop-javascript-mime-type))
      (fprintf p "hop_init_vpaned( ~s, ~s, ~s, ~a, function(event) {~a} )"
	       id (html-pan-id (car body)) (html-pan-id (cadr body))
	       (if (string? fraction)
		   (string-append "\"" fraction "\"")
		   fraction)
	       (cond
		  ((xml-tilde? onresize)
		   (xml-tilde->return onresize))
		  ((string? onresize)
		   onresize)
		  (else
		   "")))
      (fprint p "</script></div>")))
   
;*---------------------------------------------------------------------*/
;*    xml-write ::html-pan ...                                         */
;*---------------------------------------------------------------------*/
(define-method (xml-write obj::html-pan p backend)
   (with-access::html-pan obj (id klass body attributes)
      (display "<div id='" p)
      (display id p)
      (display "' class='hop-pan" p)
      (when (string? klass)
	 (display " " p)
	 (display klass p))
      (display "' " p)
      (xml-write-attributes attributes p backend)
      (display ">" p)
      (xml-write body p backend)
      (display "</div>" p)))