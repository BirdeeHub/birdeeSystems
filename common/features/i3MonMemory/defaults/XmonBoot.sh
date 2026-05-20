# will open left of center right of center left of left right of right
# all with --preferred setting

array=()
while read -r line; do
    array+=( "$line" )
done <<< "$(echo "$(xrandr --listmonitors)" | tail +2 | awk '{print $4}')"


xrandr --output ${array[0]} --primary --preferred
xrandr --output ${array[1]} --left-of ${array[0]} --preferred

