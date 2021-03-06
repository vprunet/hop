;*=====================================================================*/
;*    serrano/prgm/project/hop/2.4.x/runtime/param_expd.sch            */
;*    -------------------------------------------------------------    */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Wed Dec  6 18:17:19 2006                          */
;*    Last change :  Wed Feb  6 13:33:25 2013 (serrano)                */
;*    Copyright   :  2006-13 Manuel Serrano                            */
;*    -------------------------------------------------------------    */
;*    Parameters expander                                              */
;*=====================================================================*/

;*---------------------------------------------------------------------*/
;*    expand-define-parameter ...                                      */
;*---------------------------------------------------------------------*/
(define (expand-define-parameter id default setter x)
   (let ((vid (symbol-append '* id '*))
	 (set (symbol-append id '-set!)))
      `(begin
	  (define ,vid ,default)
	  ,(evepairify `(define (,id) ,vid) x)
	  ,(evepairify `(define (,set v)
			  ,(if (pair? setter)
			       `(set! ,vid (,(car setter) v))
			       `(set! ,vid v))
			  v)
		      x)
	  ,@(if (pair? setter)
		(list (evepairify `(,set (,id)) x))
		'()))))

;*---------------------------------------------------------------------*/
;*    expand-define-lazy-parameter ...                                 */
;*---------------------------------------------------------------------*/
(define (expand-define-lazy-parameter id default setter x)
   (let ((vid (symbol-append '* id '*))
	 (set (symbol-append id '-set!))
	 (key (symbol-append '* id '-key*)))
      `(begin
	  (define ,key (cons 1 2))
	  (define ,vid ,key)
	  ,(evepairify `(define (,id) (if (eq? ,vid ,key) ,default ,vid)) x)
	  ,(evepairify `(define (,set v)
			   ,(if (pair? setter)
				`(set! ,vid (,(car setter) v))
				`(set! ,vid v))
			   v)
		       x)
	  ,(when (pair? setter)
	      (evepairify `(,(car setter) ,default) x)))))

;*---------------------------------------------------------------------*/
;*    hop-define-parameter-expander ...                                */
;*---------------------------------------------------------------------*/
(define (hop-define-parameter-expander x e)
   (match-case x
      ((?- ?id ?default . ?setter)
       (e (expand-define-parameter id default setter x) e))
      (else
       (error "define-expander" "Illegal form" x))))

;*---------------------------------------------------------------------*/
;*    hop-define-lazy-parameter-expander ...                           */
;*---------------------------------------------------------------------*/
(define (hop-define-lazy-parameter-expander x e)
   (match-case x
      ((?- ?id ?default . ?setter)
       (e (expand-define-lazy-parameter id default setter x) e))
      (else
       (error "define-expander" "Illegal form" x))))
