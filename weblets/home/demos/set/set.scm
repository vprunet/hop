(module hophome_demos-set_js
   (export (init-game! cards borders scores-div
		       event
		       set-submit)))

;; will all be set in init-game!
(define submit-set! #unspecified)
(define *cards* #unspecified)
(define *score* #unspecified)
(define *borders* #unspecified)

(define *nb-selected-cards* 0)
(define *game-state* 'insert-coins)

(define (vector-for-each f v)
   (let loop ((i 0))
      (when (< i (vector-length v))
	 (f (vector-ref v i) i)
	 (loop (+ i 1)))))

(define (selected-cards)
   (let loop ((i 0)
	      (res '()))
      (if (>= i (vector-length *cards*))
	  res
	  (if (vector-ref *cards* i).selected?
	      (loop (+ i 1)
		    (cons i res))
	      (loop (+ i 1)
		    res)))))

(define (toggle-card!)
   (define (free-border)
      (let loop ((i 0))
	 (let ((border (vector-ref *borders* i)))
	    (if (string=? (node-style-get border "display") "none")
		border
		(loop (+ i 1))))))
   
   (when (eq? *game-state* 'fight)
      (if this.selected?
	  (begin
	     (set! this.selected? #f)
	     (set! *nb-selected-cards* (- *nb-selected-cards* 1))
	     (node-style-set! this.border-pic "display" "none"))
	  (unless (>= *nb-selected-cards* 3)
	     (set! this.selected? #t)
	     (set! *nb-selected-cards* (+ *nb-selected-cards* 1))
	     (let ((border (free-border)))
		(set! this.border-pic border)
		(node-style-set! border "top" (node-style-get this "top"))
		(node-style-set! border "left" (node-style-get this "left"))
		(node-style-set! border "display" "block"))
	     (if (= *nb-selected-cards* 3)
		 (let ((set (selected-cards)))
		    (submit-set! set)))))))

(define (update-score score)
   (let* ((rows (map (lambda (p)
			(<TR> (<TD> (car p)) (<TD> (cdr p))))
		     score))
	  (l (<TABLE> rows)))
      (if (dom-has-child-nodes? *score*)
	  (dom-replace-child! *score* l (dom-first-child *score*))
	  (dom-append-child! *score* l))))

(define (card-desc->pic-path desc)
   (let ((nb (car desc))
	 (color (cadr desc))
	 (texture (caddr desc))
	 (form (cadddr desc)))
      (string-append
       "pics/"
       (case color
	  ((red) "r")
	  ((green) "g")
	  ((blue) "b"))
       (case form
	  ((circle) "c")
	  ((rectangle) "r")
	  ((wave) "w"))
       (number->string nb)
       (case texture
	  ((full) "f")
	  ((half) "h")
	  ((empty) "e"))
       ".png")))

(define (card-desc->alt-desc desc)
   (with-output-to-string
      (lambda () (print desc))))

(define (new-board board)
   (vector-for-each (lambda (c)
		       (set! c.selected? #f))
		    *cards*)
   (set! *nb-selected-cards* 0)
   (let loop ((i 0))
      (when (< i 3)
	 (node-style-set! (vector-ref *borders* i) "display" "none")
	 (loop (+ i 1))))
   (let loop ((i 0))
      (when (< i (vector-length board))
	 (let ((card (vector-ref *cards* i))
	       (card-desc (vector-ref board i)))
	    (set! card.src (card-desc->pic-path card-desc))
	    (set! card.alt (card-desc->alt-desc card-desc)))
	 (loop (+ i 1))))
   (set! *game-state* 'fight))

(define (init-game! cards borders scores-div
		    event
		    set-submit)

   (add-event-listener! server event event-handler)
   (set! submit-set! set-submit)
   (set! *cards* cards)
   (set! *borders* borders)
   (set! *score* scores-div)
   (vector-for-each (lambda (card i)
		       (set! card.selected? #f)
		       (set! card.index i)
		       (set! card.src "pics/waiting.png")
		       (set! card.onclick toggle-card!))
		    cards)
   (set! *game-state* 'ready))

(define (event-handler event)
   (let ((response event.value))
      (if (pair? response)
	  (let ((fst (car response)))
	     (case fst
		((board)
		 (new-board (cadr response)))
		((score)
		 (update-score (cadr response)))
		((winner)
		 (set! *game-state* 'game-over)
		 (vector-for-each (lambda (card i)
				     (node-style-set! card "cursor" "default"))
				  *cards*)
		 (alert (string-append "And the winner is ... "
				       (cadr response )))))))))
