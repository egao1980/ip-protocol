(in-package #:ip-protocol/tests)

(deftest ipv4-network-contains
  (let ((net (parse-network "192.168.0.0/24")))
    (ok (ip-network-p net))
    (ok (ip-contains-p net (parse-ip "192.168.0.10")))
    (ng (ip-contains-p net (parse-ip "192.168.1.10")))
    (ok (= 256 (network-size net)))
    (ok (search "/24" (network-string net)))))

(deftest ipv4-overlaps
  (ok (ip-overlaps-p (parse-network "10.0.0.0/16") (parse-network "10.0.1.0/24")))
  (ng (ip-overlaps-p (parse-network "10.0.0.0/24") (parse-network "10.1.0.0/24"))))

(deftest ipv6-network
  (let ((net (parse-network "2001:db8::/32")))
    (ok (ip-contains-p net (parse-ip "2001:db8::1")))
    (ng (ip-contains-p net (parse-ip "2001:db9::1")))))

(deftest mixed-family-no-contain
  (ng (ip-contains-p (parse-network "10.0.0.0/8") (parse-ip "::1"))))
