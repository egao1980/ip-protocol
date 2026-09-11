(in-package #:ip-protocol)

(define-condition ip-error (error)
  ((message :initarg :message :reader ip-error-message :initform nil))
  (:report (lambda (c s)
             (format s "IP error~@[: ~A~]" (ip-error-message c)))))

(define-condition ip-parse-error (ip-error) ())
