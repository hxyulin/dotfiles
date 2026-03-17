# Starship prompt
if command -q starship
    starship init fish | source
end

# Zoxide
if command -q zoxide
    zoxide init fish --cmd cd | source
end

# fnm
if command -q fnm
    fnm env --use-on-cd --shell fish | source
end

# prj-cli (no fish support yet)
# if command -q prj
#     prj init fish --cmd pj | source
# end
