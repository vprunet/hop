;*=====================================================================*/
;*    serrano/prgm/project/hop/2.1.x/runtime/hop-sym.scm               */
;*    -------------------------------------------------------------    */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Mon Nov 27 09:39:08 2006                          */
;*    Last change :  Fri May 21 11:38:17 2010 (serrano)                */
;*    Copyright   :  2006-10 Manuel Serrano                            */
;*    -------------------------------------------------------------    */
;*    HTML symbols (special characters).                               */
;*=====================================================================*/

;*---------------------------------------------------------------------*/
;*    The module                                                       */
;*---------------------------------------------------------------------*/
(module __hop_hop-sym

   (import  __hop_xml)
   
   (export  (<SYM> ::obj)
	    (hop-symbol-alist)))

;*---------------------------------------------------------------------*/
;*    *symbol-table* ...                                               */
;*---------------------------------------------------------------------*/
(define *symbol-table*
   ;; a complete encoding can be found at:
   ;; http://theorem.ca/~mvcorks/cgi-bin/unicode.pl.cgi?start=2190&end=21FF
   (let ((t (make-hashtable)))
      (for-each (lambda (e)
		   (hashtable-put! t (car e) (cadr e)))
		'(("hyphen" "&shy;")
		  ("iexcl" "&#161;")
		  ("cent" "&#162;")
		  ("pound" "&#163;")
		  ("currency" "&#164;")
		  ("yen" "&#165;")
		  ("section" "&#167;")
		  ("mul" "&#168;")
		  ("copyright" "&#169;")
		  ("female" "&#170;")
		  ("lguillemet" "&#171;")
		  ("not" "&#172;")
		  ("registered" "&#174;")
		  ("degree" "&#176;")
		  ("plusminus" "&#177;")
		  ("micro" "&#181;")
		  ("paragraph" "&#182;")
		  ("middot" "&#183;")
		  ("male" "&#184;")
		  ("rguillemet" "&#187;")
		  ("1/4" "&#188;")
		  ("1/2" "&#189;")
		  ("3/4" "&#190;")
		  ("iquestion" "&#191;")
		  ("Agrave" "&#192;")
		  ("Aacute" "&#193;")
		  ("Acircumflex" "&#194;")
		  ("Atilde" "&#195;")
		  ("Amul" "&#196;")
		  ("Aring" "&#197;")
		  ("AEligature" "&#198;")
		  ("Oeligature" "&#338;")
		  ("Ccedilla" "&#199;")
		  ("Egrave" "&#200;")
		  ("Eacute" "&#201;")
		  ("Ecircumflex" "&#202;")
		  ("Euml" "&#203;")
		  ("Igrave" "&#204;")
		  ("Iacute" "&#205;")
		  ("Icircumflex" "&#206;")
		  ("Iuml" "&#207;")
		  ("ETH" "&#208;")
		  ("Ntilde" "&#209;")
		  ("Ograve" "&#210;")
		  ("Oacute" "&#211;")
		  ("Ocurcumflex" "&#212;")
		  ("Otilde" "&#213;")
		  ("Ouml" "&#214;")
		  ("times" "&#215;")
		  ("Oslash" "&#216;")
		  ("Ugrave" "&#217;")
		  ("Uacute" "&#218;")
		  ("Ucircumflex" "&#219;")
		  ("Uuml" "&#220;")
		  ("Yacute" "&#221;")
		  ("THORN" "&#222;")
		  ("szlig" "&#223;")
		  ("agrave" "&#224;")
		  ("aacute" "&#225;")
		  ("acircumflex" "&#226;")
		  ("atilde" "&#227;")
		  ("amul" "&#228;")
		  ("aring" "&#229;")
		  ("aeligature" "&#230;")
		  ("oeligature" "&#339;")
		  ("ccedilla" "&#231;")
		  ("egrave" "&#232;")
		  ("eacute" "&#233;")
		  ("ecircumflex" "&#234;")
		  ("euml" "&#235;")
		  ("igrave" "&#236;")
		  ("iacute" "&#237;")
		  ("icircumflex" "&#238;")
		  ("iuml" "&#239;")
		  ("eth" "&#240;")
		  ("ntilde" "&#241;")
		  ("ograve" "&#242;")
		  ("oacute" "&#243;")
		  ("ocurcumflex" "&#244;")
		  ("otilde" "&#245;")
		  ("ouml" "&#246;")
		  ("divide" "&#247;")
		  ("oslash" "&#248;")
		  ("ugrave" "&#249;")
		  ("uacute" "&#250;")
		  ("ucircumflex" "&#251;")
		  ("uuml" "&#252;")
		  ("yacute" "&#253;")
		  ("thorn" "&#254;")
		  ("ymul" "&#255;")
		  ;; Greek 
		  ("Alpha" "&#913;") 
		  ("Beta" "&#914;")
		  ("Gamma" "&#915;")
		  ("Delta" "&#916;")
		  ("Epsilon" "&#917;")
		  ("Zeta" "&#918;")
		  ("Eta" "&#919;")
		  ("Theta" "&#920;")
		  ("Iota" "&#921;")
		  ("Kappa" "&#922;")
		  ("Lambda" "&#923;")
		  ("Mu" "&#924;")
		  ("Nu" "&#925;")
		  ("Xi" "&#926;")
		  ("Omicron" "&#927;")
		  ("Pi" "&#928;")
		  ("Rho" "&#929;")
		  ("Sigma" "&#931;")
		  ("Tau" "&#932;")
		  ("Upsilon" "&#933;")
		  ("Phi" "&#934;")
		  ("Chi" "&#935;")
		  ("Psi" "&#936;")
		  ("Omega" "&#937;")
		  ("alpha" "&#945;")
		  ("beta" "&#946;")
		  ("gamma" "&#947;")
		  ("delta" "&#948;")
		  ("epsilon" "&#949;")
		  ("zeta" "&#950;")
		  ("eta" "&#951;")
		  ("theta" "&#952;")
		  ("iota" "&#953;")
		  ("kappa" "&#954;")
		  ("lambda" "&#955;")
		  ("mu" "&#956;")
		  ("nu" "&#957;")
		  ("xi" "&#958;")
		  ("omicron" "&#959;")
		  ("pi" "&#960;")
		  ("rho" "&#961;")
		  ("sigmaf" "&#962;")
		  ("sigma" "&#963;")
		  ("tau" "&#964;")
		  ("upsilon" "&#965;")
		  ("phi" "&#966;")
		  ("chi" "&#967;")
		  ("psi" "&#968;")
		  ("omega" "&#969;")
		  ("thetasym" "&#977;")
		  ("piv" "&#982;")
		  ;; punctuation
		  ("bullet" "&#8226;")
		  ("tbullet" "&#x2023;")
		  ("Tbullet" "&#x25B6;")
		  ("ellipsis" "&#8230;")
		  ("weierp" "&#8472;")
		  ("image" "&#8465;")
		  ("real" "&#8476;")
		  ("tm" "&#8482;")
		  ("alef" "&#8501;")
		  ;; arrows (U+2190 to U+21FF)
		  ("<-" "&#8592;")
		  ("<--" "&#8592;")
		  ("uparrow" "&#8593;")
		  ("->" "&#8594;")
		  ("->>" "&#x21A0;")
		  (">->" "&#x21A3;")
		  ("-->" "&#8594;")
		  ("|->" "&#x21A6;")
		  ("`->" "&#x21AA;")
		  ("->|" "&#x21E5;")
		  ("...>" "&#x21E2;")
		  ("downarrow" "&#8595;")
		  ("<->" "&#8596;")
		  ("<-->" "&#8596;")
		  ("<+" "&#8629;")
		  ("<=" "&#8656;")
		  ("<==" "&#8656;")
		  ("Uparrow" "&#8657;")
		  ("=>" "&#8658;")
		  ("==>" "&#8658;")
		  ("|=>" "&#x21F0;")
		  (":=>" "&#x21E8;")
		  ("Downarrow" "&#8659;")
		  ("<=>" "&#8660;")
		  ("<==>" "&#8660;")
		  ("--" "&#8213;")
		  ;; Mathematical operators 
		  ("forall" "&#8704;")
		  ("partial" "&#8706;")
		  ("exists" "&#8707;")
		  ("emptyset" "&#8709;")
		  ("infinity" "&#8734;")
		  ("nabla" "&#8711;")
		  ("in" "&#8712;")
		  ("notin" "&#8713;")
		  ("ni" "&#8715;")
		  ("prod" "&#8719;")
		  ("sum" "&#8721;")
		  ("asterisk" "&#8727;")
		  ("sqrt" "&#8730;")
		  ("propto" "&#8733;")
		  ("angle" "&#8736;")
		  ("and" "&#8743;")
		  ("or" "&#8744;")
		  ("cap" "&#8745;")
		  ("cup" "&#8746;")
		  ("integral" "&#8747;")
		  ("therefore" "&#8756;")
		  ("models" "&#8872;")
		  ("vdash" "&#8866;")
		  ("dashv" "&#8867;")
		  ("sim" "&#8764;")
		  ("cong" "&#8773;")
		  ("approx" "&#8776;")
		  ("neq" "&#8800;")
		  ("equiv" "&#8801;")
		  ("le" "&#8804;")
		  ("ge" "&#8805;")
		  ("subset" "&#8834;")
		  ("supset" "&#8835;")
		  ("nsupset" "&#8835;")
		  ("subseteq" "&#8838;")
		  ("supseteq" "&#8839;")
		  ("oplus" "&#8853;")
		  ("otimes" "&#8855;")
		  ("perp" "&#8869;")
		  ("mid" "|")
		  ("lceil" "&#8968;")
		  ("rceil" "&#8969;")
		  ("lfloor" "&#8970;")
		  ("rfloor" "&#8971;")
		  ("langle" "&#9001;")
		  ("rangle" "&#9002;")
		  ("[[" "&#10214;")
		  ("]]" "&#10215;")
		  ("<" "&#10216;")
		  (">" "&#10217;")
		  ("<<" "&#10218;")
		  (">>" "&#10219;")
		  ;; Misc
		  ("loz" "&#9674;") 
		  ("spades" "&#9824;")
		  ("clubs" "&#9827;")
		  ("hearts" "&#9829;")
		  ("diams" "&#9830;")
		  ("euro" "&#8464;")
		  ("permille" "&#8240;")
		  ("pertentouhsand" "&#8241;")
		  ;; smiley
		  (":-)" "&#9786;")
		  (":-]" "&#9787;")
		  (":-(" "&#9785;")
		  (":-|" "&#9865;")
		  ;; figure
		  ("skull" "&#9760;")
		  ("rhand" "&#9755;")
		  ("lhand" "&#9754;")
		  ("wrhand" "&#9758;")
		  ("wlhand" "&#9756;")
		  ("phone" "&#9742;")
		  ("wphone" "&#9743;")
		  ("envelope" "&#9993;")
		  ;; LaTeX 
		  ("dag" "&#8224;")
		  ("ddag" "&#8225;")
		  ("circ" "o")
		  ("top" "&#8868;")
		  ("bottom" "&#8869;")
		  ("lhd" "<")
		  ("rhd" ">")
		  ("parallel" "&#8214;")))
      t))

;*---------------------------------------------------------------------*/
;*    <SYM> ...                                                        */
;*---------------------------------------------------------------------*/
(define (<SYM> sym)
   (let ((s (if (symbol? sym) (symbol->string sym) sym)))
      (let ((e (hashtable-get *symbol-table* s)))
	 (if e
	     (instantiate::xml-verbatim (body e))
	     (error '<SYM> "Illegal symbol" sym)))))

;*---------------------------------------------------------------------*/
;*    hop-symbol-alist ...                                             */
;*---------------------------------------------------------------------*/
(define (hop-symbol-alist)
   (hashtable-map *symbol-table* cons))