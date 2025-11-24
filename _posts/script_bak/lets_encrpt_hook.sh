USER=qiuming
SRC=/etc/letsencrypt/live/qiuming.xyz
DEST="/home/$USER/project/ssl_apply/pems"

cp -aL "$SRC" "$DEST"
chown -R $USER:$USER "$DEST"
cp -r "$DEST/qiuming.xyz/" "/home/$USER/project/nginx/ssl/"
chown -R $USER:$USER "/home/$USER/project/nginx/ssl/"
docker restart nginx

# 1 1 1 * * root certbot renew --manual --preferred-challenges dns --manual-auth-hook "alidns" --manual-cleanup-hook "alidns clean" --deploy-hook "/home/qiuming/project/ssl_apply/update_ssl.sh"
