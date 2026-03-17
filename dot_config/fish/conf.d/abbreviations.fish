# Modern CLI replacements
if command -q eza
    abbr -a ls 'eza'
    abbr -a la 'eza -la'
    abbr -a lt 'eza --tree'
end

if command -q bat
    abbr -a cat 'bat'
end

if command -q dust
    abbr -a du 'dust'
end

if command -q procs
    abbr -a ps 'procs'
end
