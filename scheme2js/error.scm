;*=====================================================================*/
;*    Author      :  Florian Loitsch                                   */
;*    Copyright   :  2007-2009 Florian Loitsch, see LICENSE file       */
;*    -------------------------------------------------------------    */
;*    This file is part of Scheme2Js.                                  */
;*                                                                     */
;*   Scheme2Js is distributed in the hope that it will be useful,      */
;*   but WITHOUT ANY WARRANTY; without even the implied warranty of    */
;*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the     */
;*   LICENSE file for more details.                                    */
;*=====================================================================*/

(module error
   (import export-desc nodes)
   (export (scheme2js-error proc msg obj loc)))

(define (scheme2js-error proc msg obj loc)
   (cond
      ((Node? loc)
       (with-access::Node loc (location)
	  (scheme2js-error proc msg obj location)))
      ((epair? loc)
       (scheme2js-error proc msg obj (cer loc)))
      (else
       (match-case loc
	  ((at ?fname ?loc)
	   (error/location proc msg obj fname loc))
	  (else
	   (error proc msg obj))))))