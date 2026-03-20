# Starship prompt
if command -q starship
    starship init fish | source
end

# Zoxide
if command -q zoxide
    zoxide init fish --cmd z | source
end

# fnm
if command -q fnm
    fnm env --use-on-cd --shell fish | source
end

# prj-cli (no fish support yet)
# if command -q prj
#     prj init fish --cmd pj | source
# end

# fzf
if command -q fzf
    fzf --fish | source
end

# Atuin
if command -q atuin
    atuin init fish | source
end

# Yazi wrapper — cd to directory on exit
function yy
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (cat -- "$tmp"); and test -n "$cwd"; and test "$cwd" != (pwd)
        cd "$cwd"
    end
    rm -f -- "$tmp"
end
