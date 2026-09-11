(defsystem "ip-protocol"
  :version "0.1.0"
  :description "IPv4/IPv6 addresses and CIDR networks (stack-ip)"
  :author "egao1980"
  :license "MIT"
  :depends-on ()
  :serial t
  :pathname "src"
  :components ((:file "package")
               (:file "conditions")
               (:file "address")
               (:file "network"))
  :in-order-to ((test-op (test-op "ip-protocol/tests"))))

(defsystem "ip-protocol/tests"
  :depends-on ("ip-protocol" "rove")
  :pathname "tests"
  :serial t
  :components ((:file "package")
               (:file "address-test")
               (:file "network-test"))
  :perform (test-op (o c)
             (unless (symbol-call :rove :run c)
               (error "tests failed for ~A" (component-name c)))))
