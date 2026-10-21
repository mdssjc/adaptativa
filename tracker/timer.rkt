#lang racket/base

(require racket/date
         racket/string
         racket/format)

(provide format-date-ptbr
         format-timestamp-ptbr
         get-timestamp-ptbr
         get-timestamp-iso8601)

(define WEEKDAYS-PT
  #("Domingo" "Segunda-feira" "Terça-feira" "Quarta-feira" "Quinta-feira" "Sexta-feira" "Sábado"))

(define MONTHS-PT
  #("" "janeiro" "fevereiro" "março" "abril" "maio" "junho"
    "julho" "agosto" "setembro" "outubro" "novembro" "dezembro"))

(define (format-date-ptbr [d (current-date)] [include-weekday? #t] [include-seconds? #t])
  (define weekday (vector-ref WEEKDAYS-PT (date-week-day d)))
  (define day (date-day d))
  (define month (vector-ref MONTHS-PT (date-month d)))
  (define year (date-year d))
  (define hour (~r (date-hour d) #:min-width 2 #:pad-string "0"))
  (define minute (~r (date-minute d) #:min-width 2 #:pad-string "0"))
  (define second (~r (date-second d) #:min-width 2 #:pad-string "0"))
  (define time-str
    (if include-seconds?
        (format "~a:~a:~a" hour minute second)
        (format "~a:~a" hour minute)))
  (if include-weekday?
      (format "~a, ~a de ~a de ~a às ~a" weekday day month year time-str)
      (format "~a/~a/~a às ~a"
              (~r day #:min-width 2 #:pad-string "0")
              (~r (date-month d) #:min-width 2 #:pad-string "0")
              year
              time-str)))

(define (get-timestamp-ptbr)
  (format-date-ptbr (current-date) #t #t))

(define (get-timestamp-iso8601 [d (current-date)])
  (format "~a-~a-~aT~a:~a:~a"
          (date-year d)
          (~r (date-month d) #:min-width 2 #:pad-string "0")
          (~r (date-day d) #:min-width 2 #:pad-string "0")
          (~r (date-hour d) #:min-width 2 #:pad-string "0")
          (~r (date-minute d) #:min-width 2 #:pad-string "0")
          (~r (date-second d) #:min-width 2 #:pad-string "0")))

(define (format-timestamp-ptbr val)
  (cond
    [(date? val) (format-date-ptbr val #t #t)]
    [(not (string? val)) "Não registrado"]
    [(string=? (string-trim val) "") "Não registrado"]
    [(regexp-match #px"^([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})$" (string-trim val))
     => (lambda (m)
          (define year (string->number (list-ref m 1)))
          (define month (string->number (list-ref m 2)))
          (define day (string->number (list-ref m 3)))
          (define hour (string->number (list-ref m 4)))
          (define minute (string->number (list-ref m 5)))
          (define second (string->number (list-ref m 6)))
          (define secs (find-seconds second minute hour day month year #t))
          (format-date-ptbr (seconds->date secs #t) #t #t))]
    [else
     (let* ([s val]
            [s (string-replace s "Sunday" "Domingo")]
            [s (string-replace s "Monday" "Segunda-feira")]
            [s (string-replace s "Tuesday" "Terça-feira")]
            [s (string-replace s "Wednesday" "Quarta-feira")]
            [s (string-replace s "Thursday" "Quinta-feira")]
            [s (string-replace s "Friday" "Sexta-feira")]
            [s (string-replace s "Saturday" "Sábado")]
            [s (string-replace s "January" "janeiro")]
            [s (string-replace s "February" "fevereiro")]
            [s (string-replace s "March" "março")]
            [s (string-replace s "April" "abril")]
            [s (string-replace s "May" "maio")]
            [s (string-replace s "June" "junho")]
            [s (string-replace s "July" "julho")]
            [s (string-replace s "August" "agosto")]
            [s (string-replace s "September" "setembro")]
            [s (string-replace s "October" "outubro")]
            [s (string-replace s "November" "novembro")]
            [s (string-replace s "December" "dezembro")]
            [s (regexp-replace #px"([0-9]+)(?:st|nd|rd|th)" s "\\1")])
       (define rx-racket-pattern
         #px"^([A-Za-zÀ-ÿ-]+),\\s*([A-Za-zÀ-ÿ]+)\\s+([0-9]{1,2}),?\\s+([0-9]{4})(?:,?\\s+([0-9]{1,2}):([0-9]{2})(?::([0-9]{2}))?\\s*(am|pm)?)?")
       (cond
         [(regexp-match rx-racket-pattern s)
          => (lambda (m)
               (define weekday (list-ref m 1))
               (define month (list-ref m 2))
               (define day (list-ref m 3))
               (define year (list-ref m 4))
               (define h-str (list-ref m 5))
               (define min-str (list-ref m 6))
               (define sec-str (list-ref m 7))
               (define ampm (list-ref m 8))
               (if h-str
                   (let* ([h-num (string->number h-str)]
                          [h-24 (cond
                                  [(not ampm) h-num]
                                  [(string-ci=? ampm "pm") (if (= h-num 12) 12 (+ h-num 12))]
                                  [(string-ci=? ampm "am") (if (= h-num 12) 0 h-num)]
                                  [else h-num])]
                          [h-fmt (~r h-24 #:min-width 2 #:pad-string "0")]
                          [final-hour (if sec-str
                                          (format "~a:~a:~a" h-fmt min-str sec-str)
                                          (format "~a:~a" h-fmt min-str))])
                     (format "~a, ~a de ~a de ~a às ~a" weekday day month year final-hour))
                   (format "~a, ~a de ~a de ~a" weekday day month year)))]
         [else s]))]))
