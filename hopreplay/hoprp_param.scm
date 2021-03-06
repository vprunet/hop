;*=====================================================================*/
;*    serrano/prgm/project/hop/1.9.x/hopreplay/hoprp-param.scm         */
;*    -------------------------------------------------------------    */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Fri Nov 12 13:20:19 2004                          */
;*    Last change :  Sat Apr 26 10:05:49 2008 (serrano)                */
;*    Copyright   :  2004-08 Manuel Serrano                            */
;*    -------------------------------------------------------------    */
;*    HOPREPLAY global parameters                                      */
;*=====================================================================*/

;*---------------------------------------------------------------------*/
;*    The module                                                       */
;*---------------------------------------------------------------------*/
(module hoprp_param
   
   (library hop)
   
   (export  (hoprp-rc-file::bstring)
	    (hoprp-rc-file-set! ::bstring)

	    (hoprp-threads-num::int)
	    (hoprp-threads-num-set! ::int)
   
	    (hoprp-loop::bool)
	    (hoprp-loop-set! ::bool)

	    (hoprp-host::bstring)
	    (hoprp-host-set! ::bstring)

	    (hoprp-port::int)
	    (hoprp-port-set! ::int))
   
   (eval    (export-exports)))

;*---------------------------------------------------------------------*/
;*    hoprp-rc-file ...                                                */
;*---------------------------------------------------------------------*/
(define-parameter hoprp-rc-file
   "hopreplayrc.hop")

;*---------------------------------------------------------------------*/
;*    hoprp-threads-num ...                                            */
;*---------------------------------------------------------------------*/
(define-parameter hoprp-threads-num
   4)

;*---------------------------------------------------------------------*/
;*    hoprp-loop ...                                                   */
;*---------------------------------------------------------------------*/
(define-parameter hoprp-loop
   #f)

;*---------------------------------------------------------------------*/
;*    hoprp-host ...                                                   */
;*---------------------------------------------------------------------*/
(define-parameter hoprp-host
   "localhost")

;*---------------------------------------------------------------------*/
;*    hoprp-port ...                                                   */
;*---------------------------------------------------------------------*/
(define-parameter hoprp-port
   8080)
