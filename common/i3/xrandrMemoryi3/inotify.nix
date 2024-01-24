pkgs: xrandrMemory: watchedFile: /*bash*/pkgs.writeShellScript "runi3xrandrMemory.sh" ''
file_to_watch='${watchedFile}'

${pkgs.inotify-tools}/bin/inotifywait -m -e modify '${watchedFile}' |
while read -r directory events filename; do
    if [ "$filename" == '${watchedFile}' ]; then
        # Run your script or command here
        ${pkgs.bash}/bin/bash -c '${xrandrMemory}'
    fi
done
''
