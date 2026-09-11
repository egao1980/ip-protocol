(in-package #:ip-protocol/tests)

(deftest ipv4-roundtrip
  (let ((a (parse-ip "192.168.1.10")))
    (ok (ipv4-address-p a))
    (ok (= 4 (ip-version a)))
    (ok (string= "192.168.1.10" (ip-string a)))
    (ok (ip-equal a (parse-ip "192.168.1.10")))))

(deftest ipv4-rejects-leading-zero
  (ok (signals (parse-ip "192.168.0.01") 'ip-parse-error)))

(deftest ipv4-predicates
  (ok (ip-loopback-p (parse-ip "127.0.0.1")))
  (ok (ip-unspecified-p (parse-ip "0.0.0.0")))
  (ok (ip-private-p (parse-ip "10.1.2.3")))
  (ok (ip-private-p (parse-ip "192.168.0.1")))
  (ok (ip-private-p (parse-ip "172.16.0.1")))
  (ng (ip-private-p (parse-ip "8.8.8.8")))
  (ok (ip-link-local-p (parse-ip "169.254.1.1")))
  (ok (ip-multicast-p (parse-ip "224.0.0.1"))))

(deftest ipv6-roundtrip
  (let ((a (parse-ip "2001:db8::1")))
    (ok (ipv6-address-p a))
    (ok (= 6 (ip-version a)))
    (ok (ip-equal a (parse-ip "2001:0db8:0000:0000:0000:0000:0000:0001")))))

(deftest ipv6-predicates
  (ok (ip-unspecified-p (parse-ip "::")))
  (ok (ip-loopback-p (parse-ip "::1")))
  (ok (ip-link-local-p (parse-ip "fe80::1")))
  (ok (ip-private-p (parse-ip "fc00::1")))
  (ok (ip-multicast-p (parse-ip "ff02::1"))))
