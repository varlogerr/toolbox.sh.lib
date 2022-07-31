# `sh.lib`

* [Exit codes](./lib/excode.md)
* [`shlib_sed_*`](./lib/sed.md)
* [`shlib_msgbag_*`](./lib/msgbag.md)

## Usage in projects

```sh
# include all the libs
. {path-to-sh.lib}/main.sh
# include all the libs with aliases
. {path-to-sh.lib}/main.sh aliased
```

## Development

* install dependencies

  ```sh
  git clone https://github.com/varlogerr/toolbox.sh.vendor.git ./vendor/vendor
  cd ./vendor/vendor
  git checkout <latest-tag>
  cd -
  # initialize the project
  ./vendor/vendor/bin/vendor.sh --init .
  # install dependencies. after initialization
  # there will be only vendor itself as a dependency
  ./vendor/vendor/bin/vendor.sh
  ```
