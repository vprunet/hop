;*=====================================================================*/
;*    serrano/prgm/project/hop/2.3.x/runtime/zeroconf.scm              */
;*    -------------------------------------------------------------    */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Thu Dec 15 09:00:54 2011                          */
;*    Last change :  Mon Dec 19 08:46:27 2011 (serrano)                */
;*    Copyright   :  2011 Manuel Serrano                               */
;*    -------------------------------------------------------------    */
;*    Hop Zeroconf support                                             */
;*=====================================================================*/

;*---------------------------------------------------------------------*/
;*    The module                                                       */
;*---------------------------------------------------------------------*/
(module __hop_zeroconf
   (cond-expand
      ((and enable-avahi (library pthread) (library avahi))
       (include "zeroconf_avahi.sch"))
      (else
       (include "zeroconf_dummy.sch")))
   (export (hop-zeroconf ::pair-nil)))

;*---------------------------------------------------------------------*/
;*    hop-zeroconf ...                                                 */
;*---------------------------------------------------------------------*/
(define (hop-zeroconf svc)
   (hop-zeroconf-publish svc))
   