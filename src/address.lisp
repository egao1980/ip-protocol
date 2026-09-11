(in-package #:ip-protocol)

(defclass ip-address ()
  ((value :initarg :value :reader ip-integer)))

(defun ip-address-p (object)
  (typep object 'ip-address))

(defclass ipv4-address (ip-address) ())
(defclass ipv6-address (ip-address) ())

(defun ipv4-address-p (object)
  (typep object 'ipv4-address))

(defun ipv6-address-p (object)
  (typep object 'ipv6-address))

(defun ip-version (addr)
  (etypecase addr
    (ipv4-address 4)
    (ipv6-address 6)))

(defun ip-equal (a b)
  (and (ip-address-p a) (ip-address-p b)
       (eq (class-of a) (class-of b))
       (= (ip-integer a) (ip-integer b))))

(defun %parse-octet (s)
  (when (and (plusp (length s))
             (every #'digit-char-p s)
             (or (= (length s) 1) (char/= (char s 0) #\0) (string= s "0")))
    (let ((n (parse-integer s)))
      (when (<= 0 n 255) n))))

(defun parse-ipv4 (string)
  (let ((parts (loop for start = 0 then (1+ pos)
                     for pos = (position #\. string :start start)
                     collect (subseq string start (or pos (length string)))
                     while pos)))
    (unless (= 4 (length parts))
      (error 'ip-parse-error :message (format nil "not IPv4: ~S" string)))
    (let ((octets (mapcar #'%parse-octet parts)))
      (unless (and (= 4 (length octets)) (every #'identity octets))
        (error 'ip-parse-error :message (format nil "not IPv4: ~S" string)))
      (make-instance 'ipv4-address
                     :value (logior (ash (first octets) 24)
                                    (ash (second octets) 16)
                                    (ash (third octets) 8)
                                    (fourth octets))))))

(defun %parse-hextet (s)
  (when (and (<= 1 (length s) 4)
             (every (lambda (c) (digit-char-p c 16)) s))
    (parse-integer s :radix 16)))

(defun parse-ipv6 (string)
  (when (find #\. string)
    (error 'ip-parse-error :message "IPv4-mapped IPv6 not supported"))
  (let* ((dbl (search "::" string))
         (left (if dbl (subseq string 0 dbl) string))
         (right (if dbl (subseq string (+ dbl 2)) ""))
         (left-parts (if (zerop (length left))
                         nil
                         (loop for start = 0 then (1+ pos)
                               for pos = (position #\: left :start start)
                               collect (subseq left start (or pos (length left)))
                               while pos)))
         (right-parts (if (zerop (length right))
                          nil
                          (loop for start = 0 then (1+ pos)
                                for pos = (position #\: right :start start)
                                collect (subseq right start (or pos (length right)))
                                while pos))))
    (when (and (null dbl) (/= 8 (length left-parts)))
      (error 'ip-parse-error :message (format nil "not IPv6: ~S" string)))
    (when (and dbl (> (+ (length left-parts) (length right-parts)) 7))
      (error 'ip-parse-error :message (format nil "not IPv6: ~S" string)))
    (let* ((zeros (if dbl (- 8 (length left-parts) (length right-parts)) 0))
           (groups (append (mapcar #'%parse-hextet left-parts)
                           (make-list zeros :initial-element 0)
                           (mapcar #'%parse-hextet right-parts))))
      (unless (and (= 8 (length groups)) (every #'identity groups))
        (error 'ip-parse-error :message (format nil "not IPv6: ~S" string)))
      (make-instance 'ipv6-address
                     :value (loop for g in groups
                                  for acc = g then (logior (ash acc 16) g)
                                  finally (return acc))))))

(defun parse-ip (string)
  (unless (stringp string)
    (error 'ip-parse-error :message "parse-ip expects a string"))
  (if (find #\: string)
      (parse-ipv6 string)
      (parse-ipv4 string)))

(defun ip-string (addr)
  (etypecase addr
    (ipv4-address
     (let ((v (ip-integer addr)))
       (format nil "~D.~D.~D.~D"
               (ldb (byte 8 24) v) (ldb (byte 8 16) v)
               (ldb (byte 8 8) v) (ldb (byte 8 0) v))))
    (ipv6-address
     (let ((v (ip-integer addr)))
       (format nil "~{~(~X~)~^:~}"
               (loop for i from 7 downto 0
                     collect (ldb (byte 16 (* i 16)) v)))))))

(defun %in-cidr-p (value prefix-addr prefix-len bits)
  (let ((mask (if (zerop prefix-len)
                  0
                  (ash (1- (ash 1 prefix-len)) (- bits prefix-len)))))
    (= (logand value mask) (logand prefix-addr mask))))

(defun ip-unspecified-p (addr)
  (zerop (ip-integer addr)))

(defun ip-loopback-p (addr)
  (etypecase addr
    (ipv4-address (%in-cidr-p (ip-integer addr) (ash 127 24) 8 32))
    (ipv6-address (= (ip-integer addr) 1))))

(defun ip-multicast-p (addr)
  (etypecase addr
    (ipv4-address (%in-cidr-p (ip-integer addr) (ash 224 24) 4 32))
    (ipv6-address (%in-cidr-p (ip-integer addr) (ash #xff 120) 8 128))))

(defun ip-link-local-p (addr)
  (etypecase addr
    (ipv4-address (%in-cidr-p (ip-integer addr) (logior (ash 169 24) (ash 254 16)) 16 32))
    (ipv6-address (%in-cidr-p (ip-integer addr) (ash #xfe80 112) 10 128))))

(defun ip-private-p (addr)
  (etypecase addr
    (ipv4-address
     (let ((v (ip-integer addr)))
       (or (%in-cidr-p v (ash 10 24) 8 32)
           (%in-cidr-p v (logior (ash 172 24) (ash 16 16)) 12 32)
           (%in-cidr-p v (logior (ash 192 24) (ash 168 16)) 16 32))))
    (ipv6-address
     (%in-cidr-p (ip-integer addr) (ash #xfc 120) 7 128))))
