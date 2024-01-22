# end a command with ; to run in a terminal
term="$TERMINAL -e"
cachedir=${XDG_CACHE_HOME:-"$HOME/.cache"}
cache="$cachedir/dmenu_recent"

touch "$cache"

# cleaning
while read cmd
do
    command -v ${cmd%;} &>/dev/null || sed -i "/$cmd/d" $cache
done < <(sort -u $cache)

most_used=$(sort "$cache" | uniq -c | sort -rh | sed 's/\s*//' | cut -d' ' -f2-)
run=$((echo "$most_used"; dmenu_path | grep -vxF "$most_used") | dmenu -i "$@")

[ -z "$run" ] && exit 1

(echo "$run"; head -n 99 "$cache") > "$cache.$$"
mv "$cache.$$" "$cache"

case "$run" in
    *\;) exec $(echo $term ${run%;}) ;;
    *)   exec "$run" ;;
esac
