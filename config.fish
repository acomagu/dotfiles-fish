bind \cd delete-char

if type -q rbenv
    rbenv init - | source
end

if type -q salias
    salias __init__ | source
end

# Disable package suggestion.
function fish_command_not_found
    __fish_default_command_not_found_handler $argv
end

function ngrok
    command ngrok $argv -config $XDG_CONFIG_HOME/ngrok2/ngrok.yml
end

function search
    if _is_git_repo
        git ls-files --exclude-standard -o -c | xargs ls -d 2>/dev/null
    else
        find . -type f
    end | xargs grep --color $argv
end

if not functions -q _orig_cd
    functions -c cd _orig_cd
end

function cd
    if count $argv >/dev/null
        if test -e $argv || test $argv = -
            echo $argv
        else
            z -l $argv 2>&1 | begin
                read -l line
                and if string match -q -r '^common:' "$line"
                    read -l line
                    and echo $line
                else
                    echo $line
                    cat
                end
            end | awk '{ print $2 }'
        end
    else
        echo $HOME
        z -l | awk '{ print $2 }'
    end | sed '/^$/d' | fzf -1 | read -l p
    and _orig_cd $p
end

function _is_git_repo
    git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null
end

function _is_git_dirty
    set -l stat (git status --porcelain=v2)
    test -n "$stat"
end

function _git_branch_name
    git symbolic-ref --short HEAD 2>/dev/null
end

function _fish_right_prompt_branch_name
    if _is_git_repo
        _is_git_dirty
            and set color (set_color bryellow)
            or set color (set_color 88f)

        echo -n "$color"(_git_branch_name)
    end
end

function _fish_right_prompt_repo_info
    echo -n ' '(set_color cyan)(prompt_pwd)
end

function fish_right_prompt
    _fish_right_prompt_branch_name
    _fish_right_prompt_repo_info
end

function gcd
    find (ghq root) -maxdepth 4 -type d -name .git -printf '%P\n' | xargs -n1 dirname | fzf | read -l p
    and cd (ghq root)/$p
end

function ctf
    chromix-too ls | fzf | awk '{print $0}' | xargs chromix-too focus
end

function nvo
    if test -d $argv
        read -P'It\'s directory. Sure? ' a
        and test "$a" = 'y'
        or return
    end

    nvc ex e (realpath $argv)
end

function nvcd
    realpath $argv |read p
    nvc ex cd $p
end

function pd
    z -l $argv | sed '$d' | awk '{ print $2 }' | fzf -1
end

function pf
    find ~ | fzf -q $argv -1
end

function gbf
    git branch | awk '{ print $NF }' | fzf
end

function memo
    twty -a privmagu $argv >/dev/null
end

function gdb
    command gdb -nh -x $XDG_CONFIG_HOME/gdb/init $argv
end

function fish_prompt
    set last_status $status

    test $last_status = 0
    and set_color cyan
    or set_color yellow

    echo -n -s ' ❯'(set_color cyan)'❯ '(set_color normal)
end

# Configurations for plugins

# async-prompt
set -g async_prompt_functions fish_right_prompt

function fish_right_prompt_loading_indicator -a last_prompt
    echo -n "$last_prompt" | sed -r 's/[[:cntrl:]]\[[0-9]{1,3}m//g' | read -zl uncolored_last_prompt
    echo -n (set_color brblack)"$uncolored_last_prompt"(set_color normal)
end

function _fish_right_prompt_repo_info_loading_indicator
    echo (set_color '#aaa')' … '(set_color normal)
end

function git
    if test -z "$argv"
        command git
        return
    end

    switch $argv[1]
        case push
            set -l ghuser acomagu
            if test -z (git remote)
                and git rev-parse --show-toplevel | sed 's|^'(ghq root)"/github.com/$ghuser/\(.*\)\$|\1|" | read -l dirname
                and read -P"Set git@github.com:$ghuser/$dirname as origin remote branch? [Y/n]: " -l ans
                and contains "$ans" y Y ''

                command git remote add origin git@github.com:$ghuser/$dirname
            end

            set -l head
            if not string join \n -- $argv | sed 1d | grep -E '^[^-]' >/dev/null
                and command git status -b --porcelain=v2 | grep -E 'upstream|head' | cut -d' ' -f3 | begin
                    read head
                    and not read -l upstream
                end
                and command git remote get-url origin >/dev/null
                and read -P"Set origin/$head as the upstream branch? [Y/n]: " -l ans
                and contains "$ans" y Y ''

                command git $argv -u origin $head
            else
                command git $argv
            end
        case add
            command git $argv
            and command git status
        case chb
            git branch --sort=-committerdate --color | fzf --reverse --ansi | awk '{ print $NF }' | xargs git checkout
        case '*'
            command git $argv
    end
end

function yay
    if test -z "$argv"
        command yay --sudoloop -Syu
    end
    command yay --sudoloop $argv
end

function genid
    python3 -c "import string,random;print(''.join(random.choices(string.ascii_uppercase+string.ascii_lowercase+string.digits,k=3)))"
end

function hugo
    set -l cmd $argv[1]
    switch "$cmd"
        case new
            set -l cmd $argv[2]
            switch "$cmd"
                case image
                    set -l id $argv[3]
                    set -l path $argv[4]
                    set -l ext (echo $path | awk -F. '{ print $NF }')
                    set -l fname (genid).$ext
                    mkdir -p static/assets/$id
                    and cp $path static/assets/$id/$fname
                    and echo "![](/assets/$id/$fname)"
                    return
            end
    end

    command hugo $argv
end

function goinstall
    if test $GO111MODULE != on
        echo 'GO111MODULE is not on' >&2
        return 1
    end

    set -l mod
    if test (count $argv) -ge 1
        set mod $argv
    else
        set mod (pwd | sed -n 's|.*\(github.com/[^/]\+/[^/]\+\).*|\1|p')
    end
    if test (count $mod) -ne 1
        echo "Could not determine the module name: $mod" >&2
        return 1
    end

    set -l prodrt "$GHQ_ROOT/$mod"
    test -e $prodrt/go.mod || echo "module $mod" > $prodrt/go.mod
    echo "
        cd $prodrt
        go install
    " | fish
end

function goget
    ghq get -p --shallow https://$argv
    goinstall $argv
end

function encode-uri
    if test -z "$argv"
        cat
    else
        echo $argv
    end | python3 -c "import urllib.parse;print(urllib.parse.quote(input()))"
end

function youtube-dl
    command youtube-dl --no-mtime $argv
end

function diff
    git diff --no-index $argv
end

function sshfs
    command sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=1 $argv
end

function switch-insomnia-conf
    set -l confs $XDG_CONFIG_HOME/Insomnia-*
    string join \n $confs | fzf --height=10 | read -l selection
    test -z "$selection"
    and return 1

    rm -rf "$XDG_CONFIG_HOME/Insomnia"
    cp -r "$selection" "$XDG_CONFIG_HOME/Insomnia"
end
