;*=====================================================================*/
;*    serrano/prgm/project/hop/3.1.x/js2scheme/narrow.scm              */
;*    -------------------------------------------------------------    */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Fri Dec 25 07:41:22 2015                          */
;*    Last change :  Sat Apr 23 06:05:08 2016 (serrano)                */
;*    Copyright   :  2015-16 Manuel Serrano                            */
;*    -------------------------------------------------------------    */
;*    Narrow local variable scopes                                     */
;*    -------------------------------------------------------------    */
;*    This optimization consists in transforming global VAR decl into  */
;*    LET-OPT bindings.                                                */ 
;*=====================================================================*/

;*---------------------------------------------------------------------*/
;*    The module                                                       */
;*---------------------------------------------------------------------*/
(module __js2scheme_narrow

   (import __js2scheme_ast
	   __js2scheme_dump
	   __js2scheme_utils
	   __js2scheme_compile
	   __js2scheme_stage
	   __js2scheme_lexer)

   (static (class J2SNarrowInfo
	      (deffun::obj (default #f))
	      (defblock::obj (default #f))
	      (narrowable::bool (default #t))
	      (ldecl (default #f))))

   (export j2s-narrow-stage
	   (generic j2s-narrow ::obj ::obj)))

;*---------------------------------------------------------------------*/
;*    j2s-narrow-stage                                                 */
;*---------------------------------------------------------------------*/
(define j2s-narrow-stage
   (instantiate::J2SStageProc
      (name "narrow")
      (comment "Narrow resolution")
      (proc j2s-narrow)))

;*---------------------------------------------------------------------*/
;*    j2s-narrow ...                                                   */
;*---------------------------------------------------------------------*/
(define-generic (j2s-narrow this conf)
   this)

;*---------------------------------------------------------------------*/
;*    j2s-narrow ::J2SProgram ...                                      */
;*    -------------------------------------------------------------    */
;*    Warning, headers are not scanned for variable resolution!        */
;*---------------------------------------------------------------------*/
(define-method (j2s-narrow this::J2SProgram conf)
   (with-access::J2SProgram this (decls nodes headers)
      ;; mark that header declarations are not narrowalbe
      (for-each j2s-mark-unnarrowable headers)
      ;; statement optimization
      (for-each (lambda (o)
		   (cond
		      ((isa? o J2SDeclFun)
		       (with-access::J2SDeclFun o (id val)
			  ;; (tprint "Narrow " id)
			  (j2s-narrow-fun! val)))
		      ((isa? o J2SDecl)
		       (j2s-mark-unnarrowable o))))
	 decls)
      ;; nodes
      (set! nodes
	 (map! (lambda (o)
		  (j2s-find-init-blocks o #f #f)
		  (j2s-mark-narrowable o '() #f (and (isa? o J2SFun) o) (make-cell #f))
		  (j2s-narrow! o))
	    nodes)))
   this)

;*---------------------------------------------------------------------*/
;*    j2s-narrow-fun! ...                                              */
;*---------------------------------------------------------------------*/
(define (j2s-narrow-fun! o::J2SFun)
   (with-access::J2SFun o (body)
      ;; find the declaring block of all declarations
      (j2s-find-init-blocks body #f o)
      ;; get the set of narrowable declrations
      (j2s-mark-narrowable body '() #f o (make-cell #f))
      ;; narrow the function body
      (j2s-narrow! body)))

;*---------------------------------------------------------------------*/
;*    j2s-init-blocks! ...                                             */
;*    -------------------------------------------------------------    */
;*    For each declaration, finds the block that initializes it.       */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-find-init-blocks this::J2SNode block fun)
   (call-default-walker))

;*---------------------------------------------------------------------*/
;*    j2s-find-init-blocks ::J2SFun ...                                */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-find-init-blocks this::J2SFun blocks fun)
   (with-access::J2SFun this (body)
      (j2s-find-init-blocks body #f this)))

;*---------------------------------------------------------------------*/
;*    j2s-find-init-blocks ::J2SBlock ...                              */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-find-init-blocks this::J2SBlock block fun)
   (with-access::J2SBlock this (nodes)
      (for-each (lambda (b) (j2s-find-init-blocks b this fun)) nodes)))

;*---------------------------------------------------------------------*/
;*    j2s-find-init-blocks ::J2SInit ...                               */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-find-init-blocks this::J2SInit block fun)
   (when block
      (with-access::J2SInit this (lhs rhs)
	 (j2s-find-init-blocks rhs block fun)
	 (when (isa? lhs J2SRef)
	    (with-access::J2SRef lhs (decl)
	       (unless (or (j2s-let? decl) (j2s-param? decl))
		  ;; skip let/const declarations
		  (with-access::J2SDecl decl (%info)
		     (if (isa? %info J2SNarrowInfo)
			 (with-access::J2SNarrowInfo %info (narrowable)
			    (set! narrowable #f))
			 (set! %info
			    (instantiate::J2SNarrowInfo
			       (deffun fun)
			       (defblock block)))))))))))

;*---------------------------------------------------------------------*/
;*    j2s-find-init-blocks ::J2SRef ...                                */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-find-init-blocks this::J2SRef block fun)
   (with-access::J2SRef this (decl)
      (unless (or (j2s-let? decl) (j2s-param? decl))
	 ;; skip let/const declarations
	 (with-access::J2SDecl decl (%info)
	    (unless (isa? %info J2SNarrowInfo)
	       (set! %info
		  (instantiate::J2SNarrowInfo
		     (narrowable #f))))))))

;*---------------------------------------------------------------------*/
;*    j2s-mark-unnarrowable ...                                        */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-mark-unnarrowable this::J2SNode)
   (call-default-walker))

;*---------------------------------------------------------------------*/
;*    j2s-mark-unnarrowable ::J2SDecl ...                              */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-mark-unnarrowable this::J2SDecl)
   (with-access::J2SDecl this (%info)
      (set! %info
	 (instantiate::J2SNarrowInfo
	    (narrowable #f)))))

;*---------------------------------------------------------------------*/
;*    j2s-mark-narrowable ...                                          */
;*    -------------------------------------------------------------    */
;*    A var declaration is narrowable if all the following conditions  */
;*    are meet:                                                        */
;*      1- it is never used outside its bounding block                 */
;*      2- it is never captured inside a loop                          */
;*      3- it is never used after a yield inside a loop                */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-mark-narrowable this::J2SNode blocks inloop fun yield)
   (call-default-walker))

;*---------------------------------------------------------------------*/
;*    j2s-mark-narrowable ::J2SBlock ...                               */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-mark-narrowable this::J2SBlock blocks inloop fun yield)
   (let ((nblocks (cons this blocks)))
      (with-access::J2SBlock this (nodes)
	 (for-each (lambda (b) (j2s-mark-narrowable b nblocks inloop fun yield))
	    nodes))))

;*---------------------------------------------------------------------*/
;*    j2s-mark-narrowable ::J2SRef ...                                 */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-mark-narrowable this::J2SRef blocks inloop fun yield)
   (with-access::J2SRef this (decl)
      (with-access::J2SDecl decl (%info id)
	 (when (isa? %info J2SNarrowInfo)
	    (with-access::J2SNarrowInfo %info (deffun defblock narrowable)
	       (unless (and (memq defblock blocks)
			    (or (not inloop)
				(and (eq? fun deffun) (not (cell-ref yield)))))
		  (set! narrowable #f)))))))

;*---------------------------------------------------------------------*/
;*    j2s-mark-narrowable ::J2SFun ...                                 */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-mark-narrowable this::J2SFun blocks inloop fun yield)
   (with-access::J2SFun this (body)
      (j2s-mark-narrowable body blocks inloop this yield)))

;*---------------------------------------------------------------------*/
;*    j2s-mark-narrowable ::J2SLoop ...                                */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-mark-narrowable this::J2SLoop blocks inloop fun yield)
   (with-access::J2SLoop this (body)
      (let ((res (j2s-mark-narrowable body blocks #t fun yield)))
	 (unless inloop (cell-set! yield #f))
	 res)))

;*---------------------------------------------------------------------*/
;*    j2s-mark-narrowable ::J2SYield ...                               */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-mark-narrowable this::J2SYield blocks inloop fun yield)
   (with-access::J2SYield this (expr)
      (cell-set! yield #t)
      (j2s-mark-narrowable expr blocks inloop fun yield)))

;*---------------------------------------------------------------------*/
;*    j2s-narrow! ...                                                  */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-narrow! this::J2SNode)
   (call-default-walker))

;*---------------------------------------------------------------------*/
;*    j2s-narrow! ::J2SDecl ...                                        */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-narrow! this::J2SDecl)
   (call-default-walker)
   (with-access::J2SDecl this (loc %info)
      (or (when (isa? %info J2SNarrowInfo)
	     (with-access::J2SNarrowInfo %info (defblock narrowable)
		(when narrowable
		   (instantiate::J2SNop (loc loc)))))
	  this)))

;*---------------------------------------------------------------------*/
;*    j2s-narrow! ::J2SRef ...                                         */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-narrow! this::J2SRef)
   (with-access::J2SRef this (decl)
      (with-access::J2SDecl decl (%info)
	 (if (isa? %info J2SNarrowInfo)
	     (with-access::J2SNarrowInfo %info (ldecl narrowable)
		(if narrowable
		    (begin
		       (set! decl ldecl)
		       this)
		    (call-default-walker)))
	     (call-default-walker)))))

;*---------------------------------------------------------------------*/
;*    j2s-narrow! ::J2SStmtExpr ...                                    */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-narrow! this::J2SStmtExpr)
   
   (define (decl->let!::J2SDecl decl::J2SDecl)
      (with-access::J2SDecl decl (binder scope)
	 (set! scope 'local)
	 (set! binder 'let)
	 decl))

   (define (patch-defblock! block::J2SBlock decl::J2SDecl)
      (let loop ((block block))
	 (if (isa? block J2SLetBlock)
	     (with-access::J2SLetBlock block (decls nodes)
		(unless (memq decl decls)
		   ;; explicit test for variable re-definition
		   (set! decls (append! decls (list decl)))))
	     (with-access::J2SBlock block (endloc loc nodes %info)
		(if (isa? %info J2SLetBlock)
		    (loop %info)
		    (let ((lblock (instantiate::J2SLetBlock
				     (endloc endloc)
				     (loc loc)
				     (decls (list decl))
				     (nodes nodes))))
		       (set! nodes (list lblock))
		       (set! %info lblock)))))))
   
   (with-access::J2SStmtExpr this (expr)
      (or (when (isa? expr J2SInit)
	     (with-access::J2SInit expr (lhs rhs loc)
		(when (isa? lhs J2SRef)
		   (with-access::J2SRef lhs (decl)
		      (when (isa? decl J2SDecl)
			 (with-access::J2SDecl decl (id %info)
			    (when (isa? %info J2SNarrowInfo)
			       (with-access::J2SNarrowInfo %info (narrowable defblock ldecl)
				  (when narrowable
				     ;; (tprint "  +-- NARROWING: " id)
				     (set! ldecl (decl->let! decl))
				     (patch-defblock! defblock ldecl)
				     this)))))))))
	  (call-default-walker))))

;*---------------------------------------------------------------------*/
;*    j2s-narrow! ::J2SBlock ...                                       */
;*---------------------------------------------------------------------*/
(define-walk-method (j2s-narrow! this::J2SBlock)
   (call-default-walker)
   (with-access::J2SBlock this (nodes)
      (set! nodes (filter! (lambda (n) (not (isa? n J2SNop))) nodes))
      this))
   
;*---------------------------------------------------------------------*/
;*    j2s-narrow! ::J2SFun ...                                         */
;*---------------------------------------------------------------------*/
;* (define-walk-method (j2s-narrow! this::J2SFun)                      */
;*    (call-default-walker))                                           */
;*    (j2s-narrow-fun! this)                                           */
;*    this)                                                            */
