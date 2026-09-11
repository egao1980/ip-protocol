# ip-protocol

IPv4 / IPv6 addresses and CIDR networks for [cl-stack](https://github.com/egao1980/cl-stack). Pure Lisp. No IPv4-mapped IPv6 in 0.1.0.

```lisp
(asdf:load-system "ip-protocol")

(let ((net (stack-ip:parse-network "192.168.0.0/24"))
      (addr (stack-ip:parse-ip "192.168.0.10")))
  (stack-ip:ip-contains-p net addr)
  (stack-ip:ip-private-p addr))
```

## License

MIT — see [LICENSE](LICENSE).
