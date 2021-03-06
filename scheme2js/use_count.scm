;*=====================================================================*/
;*    Author      :  Florian Loitsch                                   */
;*    Copyright   :  2007-13 Florian Loitsch, see LICENSE file         */
;*    -------------------------------------------------------------    */
;*    This file is part of Scheme2Js.                                  */
;*                                                                     */
;*   Scheme2Js is distributed in the hope that it will be useful,      */
;*   but WITHOUT ANY WARRANTY; without even the implied warranty of    */
;*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the     */
;*   LICENSE file for more details.                                    */
;*=====================================================================*/

(module use-count
   (import nodes
	   export-desc
	   walk
	   verbose)
   (export (use-count tree::Module)))

;; counts the number of times a variable is referenced.
;; Set!s are not counted. -> variables with use count 0 are unused.
;; exported and imported variables are counted to have one use outside the
;; module.
(define (use-count tree)
   (count tree #f))

(define (clean-var var::Var)
   (with-access::Var var (uses id)
      (set! uses 0)))

(define-nmethod (Node.count)
   (default-walk this))

(define (count+ var::Var)
   (with-access::Var var (uses)
      (set! uses (+fx uses 1))))

(define-nmethod (Module.count)
   (with-access::Module this (this-var scope-vars runtime-vars imported-vars declared-vars)
      ;; we don't count this-initialization as 'use'.
      (with-access::Var this-var (uses) (set! uses 0))
      ;; imported and runtime-vars could be incremented or not. we decided for
      ;; not (more efficient).
      ;; scope-vars are exported. -> they are used out there...
      (for-each clean-var scope-vars) ;; first clean them.
      (for-each clean-var declared-vars)
      (for-each count+ scope-vars))
   (default-walk this))

(define-nmethod (Scope.count)
   (when (isa? this Lambda)
      (with-access::Lambda this (this-var declared-vars)
	 (with-access::Var this-var (uses)
	    (set! uses 0))
	 (for-each clean-var declared-vars)))
   (with-access::Scope this (scope-vars)
      (for-each clean-var scope-vars))
   (default-walk this))

(define-nmethod (Ref.count)
   (with-access::Ref this (var)
      (count+ var)))

(define-nmethod (Set!.count)
   (with-access::Set! this (val)
      (walk val)))

(define-nmethod (Frame-alloc.count)
   (with-access::Frame-alloc this (storage-var vars)
      (count+ storage-var)
      (for-each count+ vars)))

(define-nmethod (Frame-push.count)
   (with-access::Frame-push this (frame-alloc)
      (with-access::Frame-alloc frame-alloc (storage-var)
	 (count+ storage-var)))
   (default-walk this))
