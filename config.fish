bind \cd delete-char

set async_prompt_debug_log_enable 0

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

function _is_jj_repo
    jj st >/dev/null 2>&1
end

function _is_jj_dirty
    test (jj show -T 'empty ++ "\\n"' | head -n1) = false
end

function _jj_description
    jj show -T description | head -n1
end

function _fish_right_prompt_branch_name
    if _is_jj_repo
        _is_jj_dirty
            and set color (set_color bryellow)
            or set color (set_color 88f)

        echo -n "$color"(_jj_description)
    else if _is_git_repo
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

# マップする必要あり
function fzf-docker-continer-name-select
    commandline -i (
        env FZF_DEFAULT_COMMAND="docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Command}}\t{{.RunningFor}}\t{{.Ports}}\t{{.Networks}}'" \
        fzf --no-sort --height 80% --bind='p:toggle-preview' --preview-window=down:70% \
            --preview '
                containername=$(echo {} | awk -F " " \'{print $2}\');
                if [ "$containername" != "ID" ]; then
                    docker logs --tail 300 $containername
                fi
            ' | awk -F " " '{print $2}'
    )
end

function fzf-git-log
  git log -n1000 --oneline --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" $argv |\
    fzf -m --ansi --no-sort --reverse --tiebreak=index --preview 'f() {
      set -- $(echo "$@" | grep -o "[a-f0-9]\{7\}" | head -1);
      if [ $1 ]; then
        git show --color $1
      else
        echo "blank"
      fi
    }; f {}' |\
    grep -o "[a-f0-9]\{7\}"
end

mise activate fish | source

atuin init fish | source
