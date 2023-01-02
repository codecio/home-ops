# Prepare sops

Any prep work for sops.

## git diff config

create a `.gitattributes` file at the root.

    *.sops.* diff=sopsdiffer

Add sops command to git configuration file.

    git config diff.sopsdiffer.textconv "sops -d"
    grep -A 1 sopsdiffer .git/config
    [diff "sopsdiffer"]
            textconv = "sops -d"
