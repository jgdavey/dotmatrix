[ -e "$SOURCE_DIR" ] || SOURCE_DIR="$HOME/src"
export SOURCE_DIR

# Paths for prepending
for dir in /usr/local/bin "$HOME/bin" .git/safe/../../bin; do
  case "$PATH:" in
    *:"$dir":*) PATH="`echo "$PATH"|sed -e "s#:$dir##"`" ;;
  esac
  case "$dir" in
    /*) [ ! -d "$dir" ] || PATH="$dir:$PATH" ;;
    *) PATH="$dir:$PATH" ;;
  esac
done

# Paths for appending
for dir in /usr/local/sbin /opt/local/sbin /usr/X11/bin; do
  case ":$PATH:" in
    *:"$dir":*) ;;
    *) [ ! -d "$dir" ] || PATH="$PATH:$dir" ;;
  esac
done
