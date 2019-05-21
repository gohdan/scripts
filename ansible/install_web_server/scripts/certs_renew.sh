#!/bin/sh
/usr/bin/certbot renew
/usr/bin/systemctl reload nginx
