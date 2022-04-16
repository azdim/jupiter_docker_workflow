
#!/usr/bin/dumb-init /bin/ash

# Run commands as pack user, unless env is set
if [ -z "${RUN_AS_ROOT}" ]; then
  cd /home/pack
  set -- su-exec pack ${@}
  cd /home/nomad
  set -- su-exec nomad ${@}
fi

exec ${@}
