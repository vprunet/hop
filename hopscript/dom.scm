;*=====================================================================*/
;*    serrano/prgm/project/hop/3.0.x/hopscript/dom.scm                 */
;*    -------------------------------------------------------------    */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Fri Jun 19 13:51:54 2015                          */
;*    Last change :  Thu Jul 30 15:41:36 2015 (serrano)                */
;*    Copyright   :  2015 Manuel Serrano                               */
;*    -------------------------------------------------------------    */
;*    Server-side DOM API implementation                               */
;*=====================================================================*/

;*---------------------------------------------------------------------*/
;*    The module                                                       */
;*---------------------------------------------------------------------*/
(module __hopscript_dom

   (library hop hopwidget)
   
   (include "stringliteral.sch")
   
   (import __hopscript_types
	   __hopscript_string
	   __hopscript_stringliteral
	   __hopscript_function
	   __hopscript_number
	   __hopscript_math
	   __hopscript_boolean
	   __hopscript_regexp
	   __hopscript_array
	   __hopscript_arraybuffer
	   __hopscript_arraybufferview
	   __hopscript_date
	   __hopscript_error
	   __hopscript_json
	   __hopscript_service
	   __hopscript_property
	   __hopscript_private
	   __hopscript_public
	   __hopscript_worker
	   __hopscript_websocket
	   __hopscript_lib))

;*---------------------------------------------------------------------*/
;*    JsStringLiteral begin                                            */
;*---------------------------------------------------------------------*/
(%js-jsstringliteral-begin!)

;*---------------------------------------------------------------------*/
;*    js-cast-object ::xml-markup ...                                  */
;*---------------------------------------------------------------------*/
(define-method (js-cast-object o::xml-markup %this name)
   o)

;*---------------------------------------------------------------------*/
;*    js-get ::xml-markup ...                                          */
;*---------------------------------------------------------------------*/
(define-method (js-get o::xml-markup prop %this::JsGlobalObject)
   (let loop ((pname (js-toname prop %this)))
      (case pname
	 ((tagName)
	  (with-access::xml-markup o (tag)
	     (js-string->jsstring (symbol->string tag))))
	 ((inspect)
	  (js-make-function %this js-inspect 1 'inspect))
	 ((constructor)
	  (js-undefined))
	 ((toString)
	  (js-make-function %this
	     (lambda (this)
		(js-string->jsstring
		   (xml->string o (hop-xml-backend))))
	     0
	     'toString))
	 ((getElementsByTagName)
	  (js-make-function %this
	     (lambda (this tag)
		(js-vector->jsarray
		   (list->vector
		      (dom-get-elements-by-tag-name o (js-tostring tag %this)))
		   %this))
	     1
	     'getElementsByTagName))
	 (else
	  (with-access::xml-markup o (attributes)
	     (let ((c (memq (symbol->keyword pname) attributes)))
		(cond
		   ((not (pair? c))
		    (js-undefined))
		   ((string? (cadr c))
		    (js-string->jsstring (cadr c)))
		   ((isa? (cadr c) JsStringLiteral)
		    (cadr c))
		   (else
		    (cadr c)))))))))

;*---------------------------------------------------------------------*/
;*    js-get ::xml-document ...                                        */
;*---------------------------------------------------------------------*/
(define-method (js-get o::xml-document prop %this::JsGlobalObject)
  (case (js-toname prop %this)
     ((id)
      (with-access::xml-document o (id)
	 (js-string->jsstring id)))
     ((body)
      (with-access::xml-markup o (body)
	 (js-vector->jsarray
	    (list->vector
	       (map (lambda (o)
		       (if (string? o)
			   (js-string->jsstring o)
			   o))
		  body))
	    %this)))
     (else
      (call-next-method))))
   
;*---------------------------------------------------------------------*/
;*    js-get ::xml-element ...                                         */
;*---------------------------------------------------------------------*/
(define-method (js-get o::xml-element prop %this::JsGlobalObject)
   (case (js-toname prop %this)
      ((id)
       (with-access::xml-element o (id)
	  (if (string? id)
	      (js-string->jsstring id)
	      (js-undefined))))
      ((parentNode)
       (with-access::xml-element o (parent)
	  parent))
      ((childNodes)
       (with-access::xml-markup o (body)
	  (js-vector->jsarray
	     (list->vector
		(map (lambda (o)
			(if (string? o)
			    (js-string->jsstring o)
			    o))
		   body))
	     %this)))
      (else
       (call-next-method))))
   
;*---------------------------------------------------------------------*/
;*    js-put! ::xml-markup ...                                         */
;*---------------------------------------------------------------------*/
(define-method (js-put! o::xml-markup prop v throw::bool %this::JsGlobalObject)
   
   (define (->obj v)
      (cond
	 ((isa? v JsStringLiteral) (js-jsstring->string v))
	 (else v)))
   
   (let loop ((pname (symbol->keyword (js-toname prop %this))))
      (case pname
	 ((className:)
	  (loop 'class:))
	 (else
	  (with-access::xml-markup o (attributes)
	     (let ((c (memq pname attributes)))
		(cond
		   ((not (pair? c))
		    (set! attributes (cons* pname (->obj v) attributes)))
		   (else
		    (set-car! (cdr c) (->obj v))))))))))

;*---------------------------------------------------------------------*/
;*    js-put! ::xml-document ...                                       */
;*---------------------------------------------------------------------*/
(define-method (js-put! o::xml-document prop v throw::bool %this::JsGlobalObject)
   (case (js-toname prop %this)
      ((id)
       (with-access::xml-document o (id)
	  (set! id (js-tostring v %this))))
      ((body)
       #f)
      (else
       (call-next-method))))

;*---------------------------------------------------------------------*/
;*    js-put! ::xml-element ...                                        */
;*---------------------------------------------------------------------*/
(define-method (js-put! o::xml-element prop v throw::bool %this::JsGlobalObject)
   (case (js-toname prop %this)
      ((id)
       (with-access::xml-element o (id)
	  (set! id (js-tostring v %this))))
      ((childNodes)
       #f)
      ((parentNode)
       #f)
      (else
       (call-next-method))))

;*---------------------------------------------------------------------*/
;*    js-has-property ::xml-markup ...                                 */
;*---------------------------------------------------------------------*/
(define-method (js-has-property o::xml-markup name %this)
   (or (memq name '(className id attributes children getElementsByTagName))
       (let ((k (symbol->keyword name)))
	  (with-access::xml-markup o (attributes)
	     (let loop ((attributes attributes))
		(cond
		   ((null? attributes) #f)
		   ((eq? k (car attributes)) #t)
		   (else (loop (cddr attributes)))))))))

;*---------------------------------------------------------------------*/
;*    base-properties-name ...                                         */
;*---------------------------------------------------------------------*/
(define base-properties-name #f)

;*---------------------------------------------------------------------*/
;*    js-properties-name ::xml-markup ...                              */
;*---------------------------------------------------------------------*/
(define-method (js-properties-name o::xml-markup enump::bool %this::JsGlobalObject)
   (with-access::xml-markup o (attributes)
      (let loop ((attributes attributes)
		 (attrs `(,(js-string->jsstring "className")
			  ,(js-string->jsstring "attributes")
			  ,(js-string->jsstring "childNodes")
			  ,(js-string->jsstring "parentNode")
			  ,(js-string->jsstring "getElementsByTagName"))))
	 (cond
	    ((null? attributes)
	     (list->vector
		(if (or (isa? o xml-element) (isa? o xml-document))
		    (cons (js-string->jsstring "id") attrs)
		    attrs)))
	    (else
	     (loop (cddr attributes)
		(cons (js-string->jsstring (keyword->string! (car attributes)))
		   attrs)))))))

;*---------------------------------------------------------------------*/
;*    js-get-own-property ::xml-markup ...                             */
;*---------------------------------------------------------------------*/
(define-method (js-get-own-property o::xml-markup p::obj %this::JsGlobalObject)
   (let ((n (js-toname p %this)))
      (if (js-has-property o n %this)
	  (instantiate::JsValueDescriptor
	     (name n)
	     (writable #t)
	     (value (js-get o n %this))
	     (enumerable #t)
	     (configurable #f))
	  (js-undefined))))

;*---------------------------------------------------------------------*/
;*    js-get-property-value ::xml-markup ...                           */
;*---------------------------------------------------------------------*/
(define-method (js-get-property-value o::xml-markup base p %this::JsGlobalObject)
   (let ((n (js-toname p %this)))
      (if (js-has-property o n %this)
	  (js-get o n %this)
	  (js-undefined))))

;*---------------------------------------------------------------------*/
;*    js-for-in ::xml-markup ...                                       */
;*---------------------------------------------------------------------*/
(define-method (js-for-in o::xml-markup proc %this)
   (with-access::xml-markup o (id attributes)
      (let loop ((attributes attributes))
	 (when (pair? attributes)
	    (if (eq? (car attributes) 'class:)
		(proc (js-string->jsstring "className"))
		(proc (js-string->jsstring (keyword->string (car attributes)))))
	    (loop (cddr attributes))))))
	 
;*---------------------------------------------------------------------*/
;*    js-for-in ::xml-element ...                                      */
;*---------------------------------------------------------------------*/
(define-method (js-for-in o::xml-element proc %this)
   (with-access::xml-markup o (id)
      (proc (js-string->jsstring "id"))
      (call-next-method)))
	 
;*---------------------------------------------------------------------*/
;*    js-for-in ::xml-document ...                                     */
;*---------------------------------------------------------------------*/
(define-method (js-for-in o::xml-document proc %this)
   (with-access::xml-markup o (id)
      (proc (js-string->jsstring "id"))
      (call-next-method)))
	 
;*---------------------------------------------------------------------*/
;*    JsStringLiteral end                                              */
;*---------------------------------------------------------------------*/
(%js-jsstringliteral-end!)