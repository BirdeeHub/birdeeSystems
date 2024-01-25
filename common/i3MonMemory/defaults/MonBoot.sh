# will open left of center right of center left of left right of right
# all with --preferred setting

array=()
while read -r line; do
    array+=("$line")
done <<< "$(echo "$(xrandr --listmonitors)" | tail +2 | awk '{print $4}')"


xrandr --output "${array[0]}" --primary --preferred
lastMon="${array[0]}"
array=("${array[@]:1}")
xrandr --output "${array[0]}" --left-of $lastMon --preferred
pivotMon=$lastMon
lastMon="${array[0]}"
array=("${array[@]:1}")
i=0
for mon in "${array[@]}"; do
    pos="--left-of"
    $((i%2)) && pos="--right-of"
    xrandr --output $mon $pos $pivotMon --preferred
    pivotMon=$lastMon
    lastMon=$mon
done

