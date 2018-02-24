#!/usr/bin/env bash

pwned_hibp () {
  local sha=$(echo "$1" | tr -d '\n' | shasum | cut -c 1-40 | tr '[:lower:]' '[:upper:]')
  local prefix=$(echo "$sha" | cut -c 1-5)
  local suffix=$(echo "$sha" | cut -c 6-40)
  if [[ $(curl --silent "https://api.pwnedpasswords.com/range/$prefix" | grep "$suffix") ]]; then
    return 1
  fi
  return 0
}

pwned_wordlist () {
  local wordlist="$1"
  local password="$2"
  if [[ ! -f "$wordlist" ]]; then
    die "Wordlist not found"
  fi
  if [[ $(echo "$password" | grep --file="$wordlist") ]]; then
    return 1
  fi
  return 0
}

cmd_audit_password () {
  local opts wordlist use_wordlist=0 use_hibp=0
  opts="$($GETOPT -o w:p -l wordlist:,hibp -n "$PROGRAM" -- "$@")"
  local err=$?
  eval set -- "$opts"
  while true; do case $1 in
    -w|--wordlist) use_wordlist=1; wordlist="${2:-1}"; shift 2 ;;
    -h|--hibp) use_hibp=1; shift ;;
    --) shift; break ;;
  esac done

  local path="${1%/}"
  local passfile="$PREFIX/$path.gpg"
  check_sneaky_paths "$path"
  [[ -f $passfile ]] || die "Passfile not found"

  [[ $use_wordlist -eq 1 ]] || [[ $use_hibp -eq 1 ]] || die "Please use either --hibp or --wordlist"

  local password=$($GPG -d "${GPG_OPTS[@]}" "$passfile" | head -n 1 | tr -d '\n')

  local pwned=0

  if [[ $use_hibp -eq 1 ]]; then
    pwned_hibp "$password"
    if [[ $? -eq 1 ]]; then
      pwned=1
    fi
  fi

  if [[ $use_wordlist -eq 1 ]]; then
    pwned_wordlist "$wordlist" "$password"
    if [[ $? -eq 1 ]]; then
      pwned=1
    fi
  fi

  if [[ $pwned -eq 1 ]]; then
    echo "$path"
    return 1
  fi
  return 0
}


cmd_audit_all_passwords () {
  local prefix_len=$(echo "$PREFIX" | wc -c | tr -d ' ')
  local pwned=0
  for p in $(find "$PREFIX" -name "*.gpg"); do
    path=$(echo "$p" | cut -c "$prefix_len-" | cut -c 2- | sed 's/.gpg$//')
    cmd_audit_password "$@" "$path"
    if [[ $? -ne 0 ]]; then
      pwned=1
    fi
  done
  return $pwned
}

cmd_audit_usage () {
  cat <<-_EOF
Usage:

    $PROGRAM audit [--hibp,-p] [--wordlist,-w list-file] pass-name
        Check whether a password has been pwned, either by consulting Have I
        Been Pwned or a wordlist file (or both).  You can specify either or
        both options, but without at least one, nothing will happen.

    $PROGRAM audit all [--hibp,-p] [--wordlist,-w list-file]
        Check all the passwords in your store against Have I Been Pwned and/or
        the provided wordlist.

More information is available from the pass-audit(1) man page.
_EOF
  exit 0
}

case "$1" in
  help|--help|-h) shift; cmd_audit_usage "$@" ;;
  --all)          shift; cmd_audit_all_passwords "$@" ;;
  *)                     cmd_audit_password "$@" ;;
esac

exit $?

# vim: :set shiftwidth=2 expandtab:
