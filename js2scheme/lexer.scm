;*=====================================================================*/
;*    serrano/prgm/project/hop/3.0.x/js2scheme/lexer.scm               */
;*    -------------------------------------------------------------    */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Sun Sep  8 07:33:09 2013                          */
;*    Last change :  Fri May 16 09:19:31 2014 (serrano)                */
;*    Copyright   :  2013-14 Manuel Serrano                            */
;*    -------------------------------------------------------------    */
;*    JavaScript lexer                                                 */
;*=====================================================================*/

;*---------------------------------------------------------------------*/
;*    The module                                                       */
;*---------------------------------------------------------------------*/
(module __js2scheme_lexer
   (export (j2s-lexer)
	   (j2s-regex-lexer)
	   (j2s-reserved-id? ::symbol)
	   (j2s-strict-reserved-id? ::symbol)))

;*---------------------------------------------------------------------*/
;*    reserved identifiers                                             */
;*---------------------------------------------------------------------*/
(define (j2s-reserved-id? sym)
   (or (getprop sym 'reserved)
       (and *JS-care-future-reserved*
	    (getprop sym 'future-reserved))))

;*---------------------------------------------------------------------*/
;*    j2s-strict-reserved-id? ...                                      */
;*---------------------------------------------------------------------*/
(define (j2s-strict-reserved-id? sym)
   (or (getprop sym 'future-strict-reserved)
       (getprop sym 'future-reserved)))
       
(define *JS-care-future-reserved* #t)

(define *keyword-list*
   '("break"
     "case"
     "catch"
     "continue"
     "debugger"
     "default"
     "delete"
     "do"
     "else"
     "false"
     "finally"
     "for"
     "function"
     "service"
     "if"
     "in"
     "instanceof"
     "new"
     "null"
     "return"
     "switch"
     "this"
     "throw"
     "true"
     "try"
     "typeof"
     "var"
     "void"
     "while"
     "with"))

(define *future-reserved-list*
   '("class"
     "const"
     "enum"
     "export"
     "extends"
     "import"
     "super"))

(define *future-strict-reserved-list*
   '("implements"
     "interface"
     "let"
     "package"
     "private"
     "protected"
     "public"
     "static"
     "yield"))

(for-each (lambda (word)
	     (putprop! (string->symbol word) 'reserved #t))
	  *keyword-list*)

(for-each (lambda (word)
	     (putprop! (string->symbol word) 'future-reserved #t))
	  *future-reserved-list*)

(for-each (lambda (word)
	     (putprop! (string->symbol word) 'future-strict-reserved #t))
	  *future-strict-reserved-list*)

;*---------------------------------------------------------------------*/
;*    the-choord ...                                                   */
;*    -------------------------------------------------------------    */
;*    Builds a Bigloo location object                                  */
;*---------------------------------------------------------------------*/
(define (the-coord input-port offset)
   `(at ,(input-port-name input-port)
       ,(-fx (input-port-position input-port) offset)))

;*---------------------------------------------------------------------*/
;*    token ...                                                        */
;*---------------------------------------------------------------------*/
(define-macro (token type value offset)
   `(econs ,type ,value (the-coord input-port ,offset)))

;*---------------------------------------------------------------------*/
;*    j2s-grammar ...                                                  */
;*---------------------------------------------------------------------*/
(define j2s-grammar
   (regular-grammar
	 ;; TODO: are a010 and a013 really correct?
	 ((blank_u (or "\xc2\xa0"))
	  (blank (or (in #\Space #\Tab #a010 #a011 #a012 #a013 #\Newline)
		     blank_u))
	  (blank_no_lt (or (in #\Space #\Tab #a011 #a012) blank_u))
	  (lt (in #a013 #\Newline))
	  (nonzero-digit (in ("19")))
	  (e2 (or (: "\xe2" (out "\x80")) (: "\xe2\x80" (out "\xa8\xa9"))))
	  (id_part_sans (or (in #a127 #a225) (in #a227 #a255) e2))
	  (unicode_char (: (in "\xd0\xd1") (or all #\Newline)))
	  (alpha+ (or alpha unicode_char))
	  (alnum+ (or alnum unicode_char))
	  (id_start (or alpha+ #\$ #\_ id_part_sans))
	  (id_part (or alnum+ #\$ #\_ id_part_sans))
	  (id_start_u (or unicode alpha+ #\$ #\_ id_part_sans))
	  (id_part_u (or unicode alnum+ #\$ #\_ id_part_sans))
	  (letter (in ("azAZ") (#a128 #a255)))
	  (kspecial (in "!@$%^&*></-_+\\=?"))
	  (special (or kspecial #\:))
	  (tagid (: (* digit)
		    (or letter digit)
		    (* (or letter digit))))
	  (unicode (: #\\ #\u
		      (or (: (in ("0139afAF")) (= 3 (in ("09afAF"))))
			  (: "2" (in ("19afAF")) (= 2 (in ("09afAF"))))
			  (: "20" (in ("0139afAF")) (in ("09afAF")))
			  (: "202" (in ("07afAF"))))))
	  (ls "\xe2\x80\xa8")
	  (ps "\xe2\x80\xa9")
	  (line_cont (: #\\ (or "\n" "\r\n" ls ps)))
	  (string_char (or (out #a226 #\" #\' #\\ #\Return #\Newline) e2))
	  (string_char_quote (or #\' string_char))
	  (string_char_dquote (or #\" string_char)))
      
      ((+ blank_no_lt)
       (ignore))

      ((or ls ps)
       (token 'NEWLINE 'ls 1))
      
      ((: (* blank_no_lt) lt (* blank))
       (token 'NEWLINE #\newline 1))

      ;; linecomment
      ((:"//" (* (or (out "\n\xe2\r")
		     (: "\xe2" (out "\x80"))
		     (: "\xee\x80" (out "\xa8\xa9")))))
       (ignore))
      
      ;; multi-line comment on one line
      ((: "/*" (* (or (out #\*) (: (+ #\*) (out #\/ #\*)))) (+ #\*) "/")
       (ignore))

      ;; multi-line comment with LineTerminators (several lines)
      ((: "/*"
	  (* (or lt
		 (out #\*)
		 (: (+ #\*) (out #\/ #\*))))
	  (+ #\*) "/")
       (token 'NEWLINE #\newline 1))

      (#\0
       (token 'NUMBER 0 (the-length)))
      ((+ #\0)
       (token 'OCTALNUMBER 0 (the-length)))
      ((: nonzero-digit (* digit))
       ;; integer constant
       (let* ((len (the-length))
	      (val (if (>=fx len 18)
		       (flonum->bignum (string->real (the-string)))
		       (string->number (the-string)))))
	  (token 'NUMBER val len)))
      ((: (+ #\0) nonzero-digit (* digit))
       ;; integer constant
       (let* ((len (the-length))
	      (val (if (>=fx len 18)
		       (flonum->bignum (string->real (the-string)))
		       (string->number (the-string)))))
	  (token 'OCTALNUMBER val len)))
      ((: (+ digit) (: (in #\e #\E) #\- (+ digit)))
       ;; floating-point constant
       (token 'NUMBER (string->number (the-string)) (the-length)))
      ((: (or (: (+ digit) #\. (* digit)) (: #\. (+ digit)))
	  (? (: (in #\e #\E) (? (in #\- #\+)) (+ digit))))
       (token 'NUMBER (string->number (the-string)) (the-length)))
      ((: (+ digit) (: (in #\e #\E) (? #\+) (+ digit)))
       ;; a bignum
       (let* ((s (the-string))
	      (i (string-index s "eE"))
	      (base (string->bignum (substring s 0 i)))
	      (rest (string->bignum
		       (if (char=? (string-ref s (+fx i 1)) #\+)
			   (substring s (+fx i 2))
			   (substring s (+fx i 1))))))
	  (token 'NUMBER (+ 0 (*bx base (exptbx #z10 rest))) (the-length))))
       
      ((: (uncase "0x") (+ xdigit))
       (token 'NUMBER (string->number (the-substring 2 (the-length)) 16)
	  (the-length)))
      
      (#\{   (token 'LBRACE #\{ 1))
      (#\}   (token 'RBRACE #\} 1))
      (#\(   (token 'LPAREN #\( 1))
      (#\)   (token 'RPAREN #\) 1))
      (#\[   (token 'LBRACKET #\[ 1))
      (#\]   (token 'RBRACKET #\] 1))
      (#\.   (token 'DOT #\. 1))
      (#\;   (token 'SEMICOLON #\; 1))
      (#\,   (token 'COMMA #\, 1))
      (#\|   (token 'BIT_OR #\| 1))
      ("||"  (token 'OR "||" 2))
      ("|="  (token 'BIT_OR= "|=" 2))
      ((or #\< #\> "<=" ">=" "==" "!=" "===" "!==" #\+ #\- #\* #\% "++" "--"
	   "<<" ">>" ">>>" #\& #\^ #\! #\~ "&&" #\: #\= "+=" "-="  
	   "*=" "%=" "<<=" ">>=" ">>>=" "&=" "^=" "/=" #\/ #\?)
       (token (the-symbol) (the-string) (the-length)))

      ;; strings
      ((: #\" (* string_char_quote) #\")
       (token 'STRING (the-substring 1 (-fx (the-length) 1)) (the-length)))
      ((: #\' (* string_char_dquote) #\')
       (token 'STRING (the-substring 1 (-fx (the-length) 1)) (the-length)))
      ((: #\" (* (or string_char_quote (: #\\ all) line_cont)) #\")
       (escape-js-string (the-substring 1 (-fx (the-length) 1)) input-port))
      ((: #\' (* (or string_char_dquote (: #\\ all) line_cont)) #\')
       (escape-js-string (the-substring 1 (-fx (the-length) 1)) input-port))

      ((: #\# #\:
	  (: (* digit)
	     (or letter special)
	     (* (or letter special digit (in "'`")))))
       (let* ((len (the-length))
	      (sym (string->symbol (the-substring 2 len))))
	  (token (if (eq? sym 'pragma) 'PRAGMA 'HOP) sym len)))
      ("~{"
       (token 'TILDE (the-string) (the-length)))
      ("${"
       (token 'DOLLAR (the-string) (the-length)))
      
      ;; Identifiers and Keywords
      ((: id_start (* id_part))
       (let ((symbol (the-symbol)))
	  (cond
	     ((getprop symbol 'reserved)
	      (token symbol symbol (the-length)))
	     ((and *JS-care-future-reserved* (getprop symbol 'future-reserved))
	      (token 'RESERVED symbol (the-length)))
	     (else
	      (token 'ID symbol (the-length))))))

      ((: id_start_u (* id_part_u))
       (let ((str (the-string)))
	  (cond
	     ((no-line-terminator "continue\\u" str)
	      (unread-string! (substring str 0 8) (the-port))
	      (token 'continue 'continue 9))
	     ((no-line-terminator "break\\u" str)
	      (unread-string! (substring str 0 5) (the-port))
	      (token 'break 'break 5))
	     ((no-line-terminator "throw\\u" str)
	      (unread-string! (substring str 0 5) (the-port))
	      (token 'throw 'throw 5))
	     ((no-line-terminator "return\\u" str)
	      (unread-string! (substring str 0 7) (the-port))
	      (token 'return 'return 7))
	     (else
	      (let ((estr (escape-js-string str input-port)))
		 (if (memq (car estr) '(ESTRING OSTRING))
		     (let ((symbol (string->symbol (cdr estr))))
			(cond
			   ((getprop symbol 'reserved)
			    (token symbol symbol (the-length)))
			   ((and *JS-care-future-reserved*
				 (getprop symbol 'future-reserved))
			    (token symbol symbol (the-length)))
			   (else
			    (token 'ID symbol (the-length)))))
		     estr))))))

      ;; Tags (hopscript extension)
      ((: "<" tagid ">")
       (token 'OTAG (the-symbol) (the-length)))
      
      ;; Closing Tags (hopscript extension)
      ((: "</" tagid ">")
       (token 'CTAG (symbol-append '< (string->symbol (the-substring 2 -1)) '>)
	  (the-length)))
      
      ;; small HACK: 0 is used to indicate that a pragma should be inserted.
      ;; doesn't get caught by lexer... (bug?)
      ;; -> will be "retreated" in else-clause
      ;(#a000 (token 'PRAGMA #unspecified))
      
      ;; error
      (else
       (let ((c (the-failure)))
	  (cond
	     ((eof-object? c)
	      (token 'EOF c 0))
	     ((and (char? c) (char=? c #a000))
	      (token 'PRAGMA #unspecified 1))
	     (else
	      (token 'ERROR c 1)))))))

;*---------------------------------------------------------------------*/
;*    no-line-terminator ...                                           */
;*    -------------------------------------------------------------    */
;*    http://www.ecma-international.org/ecma-262/5.1/#sec-7.3          */
;*---------------------------------------------------------------------*/
(define (no-line-terminator prefix str)
   (and (string-prefix? prefix str)
	(let ((offset (string-length prefix)))
	   (or (substring-at? str "000A" offset)
	       (substring-at? str "000a" offset)
	       (substring-at? str "000D" offset)
	       (substring-at? str "000d" offset)
	       (substring-at? str "2028" offset)
	       (substring-at? str "2029" offset)))))

;*---------------------------------------------------------------------*/
;*    escape-js-string ...                                             */
;*    -------------------------------------------------------------    */
;*    http://www.ecma-international.org/ecma-262/5.1/#sec-7.8.4        */
;*---------------------------------------------------------------------*/
(define (escape-js-string str input-port)
   
   (define (err)
      (token 'ERROR str (+fx (string-length str) 1)))
   
   (define (char-alpha c)
      (cond
	 ((char>=? c #\a)
	  (when (char<=? c #\f)
	     (+fx 10 (-fx (char->integer c) (char->integer #\a)))))
	 ((char>=? c #\A)
	  (when (char<=? c #\F)
	     (+fx 10 (-fx  (char->integer c) (char->integer #\A)))))
	 ((char>=? c #\0)
	  (when (char<=? c #\9)
	     (-fx (char->integer c) (char->integer #\0))))
	 (else
	  #f)))
   
   (define (hex2 str j)
      (let ((n1 (char-alpha (string-ref str j))))
	 (when n1
	    (let ((n2 (char-alpha (string-ref str (+fx j 1)))))
	       (when n2
		  (+fx (*fx n1 16) n2))))))
   
   (define (hex4 str j)
      (let ((n1 (hex2 str j)))
	 (when n1
	    (let ((n2 (hex2 str (+fx j 2))))
	       (when n2
		  (+fx (*fx n1 256) n2))))))
   
   (define (integer->utf8 n)
      (let ((u (make-ucs2-string 1 (integer->ucs2 n))))
	 (ucs2-string->utf8-string u)))

   (define (octal? c)
      (and (char>=? c #\0) (char<=? c #\7)))

   (define (octal-char c1)
      (-fx (char->integer c1) (char->integer #\0)))
   
   (define (octal-val str index len)
      (let loop ((i index)
		 (val 0))
	 (if (or (=fx i len) (not (octal? (string-ref str i))))
	     (values val (-fx i index))
	     (loop (+fx i 1)
		(+fx (*fx val 8) (octal-char (string-ref str i)))))))
   
   (let* ((len (string-length str))
	  (res (make-string len)))
      (let loop ((i 0)
		 (w 0)
		 (octal #f))
	 (let ((j (string-index str #\\ i)))
	    (cond
	       ((not j)
		(blit-string! str i res w (-fx len i))
		(string-shrink! res (+fx w (-fx len i)))
		(token (if octal 'OSTRING 'ESTRING) res (+fx len 1)))
	       ((=fx j (-fx len 1))
		(err))
	       (else
		(when (>fx j i)
		   (blit-string! str i res w (-fx j i))
		   (set! w (+fx w (-fx j i))))
		(let ((c (string-ref str (+fx j 1))))
		   (case c
		      ((#\' #\" #\\)
		       (string-set! res w c)
		       (loop (+fx j 2) (+fx w 1) octal))
		      ((#\b)
		       (string-set! res w #a008)
		       (loop (+fx j 2) (+fx w 1) octal))
		      ((#\f)
		       (string-set! res w #a012)
		       (loop (+fx j 2) (+fx w 1) octal))
		      ((#\n)
		       (string-set! res w #a010)
		       (loop (+fx j 2) (+fx w 1) octal))
		      ((#\r)
		       (string-set! res w #a013)
		       (loop (+fx j 2) (+fx w 1) octal))
		      ((#\t)
		       (string-set! res w #a009)
		       (loop (+fx j 2) (+fx w 1) octal))
		      ((#\v)
		       (string-set! res w #a011)
		       (loop (+fx j 2) (+fx w 1) octal))
		      ((#\x)
		       (if (>=fx j (-fx len 3))
			   (err)
			   (let ((n (hex2 str (+fx j 2))))
			      (if n
				  (let* ((s (integer->utf8 n))
					 (l (string-length s)))
				     (blit-string! s 0 res w l)
				     (loop (+fx j 4) (+fx w l) octal))
				  (err)))))
		      ((#\u)
		       (if (>=fx j (-fx len 5))
			   (err)
			   (let ((n (hex4 str (+fx j 2))))
			      (if n
				  (let* ((s (integer->utf8 n))
					 (l (string-length s)))
				     (blit-string! s 0 res w l)
				     (loop (+fx j 6) (+fx w l) octal))
				  (err)))))
		      ((#\newline)
		       (loop (+fx j 2) w octal))
		      ((#\return)
		       (if (and (<fx (+fx j 2) len)
				(char=? (string-ref str (+fx j 2)) #\Newline))
			   (loop (+fx j 3) w octal)
			   (loop (+fx j 1) w octal)))
		      ((#a226)
		       (if (and (<fx (+fx j 3) len)
				(char=? (string-ref str (+fx j 2)) #a128)
				(or (char=? (string-ref str (+fx j 3)) #a168)
				    (char=? (string-ref str (+fx j 3)) #a169)))
			   (loop (+fx j 4) w octal)
			   (loop (+fx j 1) w octal)))
		      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
		       (multiple-value-bind (n lo)
			  (octal-val str (+fx j 1) len)
			  (let* ((s (integer->utf8 n))
				 (l (string-length s)))
			     (blit-string! s 0 res w l)
			     (loop (+fx j (+fx lo 1)) (+fx w l) #t))))
		      (else
		       (loop (+fx j 1) w octal))))))))))

;*---------------------------------------------------------------------*/
;*    j2s-regex-grammar ...                                            */
;*    -------------------------------------------------------------    */
;*    http://www.ecma-international.org/ecma-262/5.1/#sec-7.8.5        */
;*---------------------------------------------------------------------*/
(define j2s-regex-grammar 
   (regular-grammar ((ls "\xe2\x80\xa8")
		     (ps "\xe2\x80\xa9")
		     (lt (in #a013 #\Newline "\xe2"))
		     (e2 (or (: "\xe2" (out "\x80"))
			     (: "\xe2\x80" (out "\xa8\xa9"))))
		     (nonsep (or (out lt) e2))
		     (escape (: #\\ nonsep))
		     (range (: #\[ (* (or (out lt #\]) e2)) #\]))
		     (regexp (* (or (out #\/ #\\ #\[ lt) e2 escape range))))
      ((: regexp "/" (+ (in "igm")))
       (let* ((s (the-string))
	      (l (the-length))
	      (i (string-index-right s "/"))
	      (rx (substring s 0 i)))
	  (token 'RegExp (cons (substring s 0 i) (substring s (+fx i 1) l)) 0)))
      ((: regexp "/")
       (token 'RegExp (cons (the-substring 0 -1) "") 0))
      (else
       (let ((c (the-failure)))
	  (if (eof-object? c)
	      (token 'EOF c 0)
	      (token 'ERROR c 0))))))

;*---------------------------------------------------------------------*/
;*    j2s-lexer ...                                                    */
;*---------------------------------------------------------------------*/
(define (j2s-lexer)
   j2s-grammar)

;*---------------------------------------------------------------------*/
;*    j2s-regex-lexer ...                                              */
;*---------------------------------------------------------------------*/
(define (j2s-regex-lexer)
   j2s-regex-grammar)