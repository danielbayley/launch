#! /bin/zsh -f --ksh-glob
zparseopts -D -E -A opts -- h -help v -version \
i=install -install=install l:=label -label:=label f:=filter -filter:=filter

case ${(k)opts:-$#} in
  -h|--help|0) exec cat $0:A:h/README.md;;
  -v|--version) exec print $0:A:h:h
esac

export LABEL=${label[2]:-com.maxOS.launch.$1:t:r}
install=${(Mk)opts:#-?(-)[io]*}
plist=$opts[$install]:r
plist=${install:+${plist:-~/Library/LaunchAgents/$LABEL}.plist}

$0:A:h/lib*/*.rb $1 | ${filter[2]:-cat} | plutil -convert xml1 -o ${plist:--} -- -
