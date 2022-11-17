$TTL    3600
@       IN      SOA     ns.fabulas.com. igonzalezvila.danielcastelao.org. (
                   2007010401           ; Serial
                         3600           ; Refresh [1h]
                          600           ; Retry   [10m]
                        86400           ; Expire  [1d]
                          600 )         ; Negative Cache TTL [1h]
;
@       IN      NS      ns.fabulas.com.
@       IN      MX      10 serveremail.fabulas.org.

ns     IN       A       10.0.1.10
oscuras    IN      A       10.0.1.11
maravillosas	IN	A    10.0.1.11

pop     IN      CNAME   ns
www     IN      CNAME   etch
mail    IN      CNAME   etch
