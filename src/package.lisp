(defpackage #:ip-protocol
  (:use #:cl)
  (:nicknames #:stack-ip)
  (:export #:ip-error
           #:ip-parse-error
           #:ip-error-message

           #:ip-address
           #:ip-address-p
           #:ipv4-address
           #:ipv4-address-p
           #:ipv6-address
           #:ipv6-address-p
           #:ip-version
           #:ip-integer
           #:parse-ip
           #:ip-string
           #:ip-equal
           #:ip-loopback-p
           #:ip-unspecified-p
           #:ip-private-p
           #:ip-link-local-p
           #:ip-multicast-p

           #:ip-network
           #:ip-network-p
           #:ipv4-network
           #:ipv6-network
           #:network-address
           #:network-prefix
           #:parse-network
           #:network-string
           #:network-size
           #:ip-contains-p
           #:ip-overlaps-p))

(in-package #:ip-protocol)
