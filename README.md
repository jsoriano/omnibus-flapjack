# Flapjack Omnibus project

This project creates full-stack platform-specific packages for
[Flapjack](http://flapjack.io) using [omnibus](https://github.com/opscode/omnibus) and maintains appropriate package repositories at [packages.flapjack.io](http://packages.flapjack.io/)


You have some choice over how you run this:

- building locally
- building within a docker container

If you run locally, you'll be calling `omnibus build` directly rather than using the `build` script, which means you'll miss out on the ability to update packages.flapjack.io with the resulting package.

## Building locally

You need to have this project checked out on the target platform as cross compilation is not supported.

We'll assume you have Ruby 1.9+ and Bundler installed. First ensure all
required gems are installed and ready to use:

```shell
$ bundle install --binstubs
```

Also make sure you have fpm and the required tools to build packages (such as rpm-build on rpm based platforms) installed.

The platform/architecture type of the package created will match the platform
where the `build` command is invoked. So running this command on say a
MacBook Pro will generate a Mac OS X specific package. After the build
completes packages will be available in `pkg/`, and with a bit of luck on your package repo as well.

### Build

```shell
FLAPJACK_BUILD_REF="v1.0.0rc3" \
FLAPJACK_EXPERIMENTAL_PACKAGE_VERSION="1.0.0~rc3~20140727T125000-9b1e831-1" \
bundle exec bin/omnibus build project flapjack
```

### Clean

You can clean up all temporary files generated during the build process with
the `clean` command:

```shell
$ bin/omnibus clean flapjack
```

Adding the `--purge` purge option removes __ALL__ files generated during the
build including the project install directory (`/opt/flapjack`) and
the package cache directory (`/var/cache/omnibus/pkg`):

```shell
$ bin/omnibus clean flapjack --purge
```

### Help

Full help for the Omnibus command line interface can be accessed with the
`help` command:

```shell
$ bin/omnibus help
```

## Building within a Docker container

You'll need a docker server and a local docker command that can talk to it.
An easy way to get a docker server going is using [boot2docker](http://boot2docker.io/).
A more complicated way is to use an EC2 instance, which is what we use for the official packages.
There's a [packer config](packer-ebs.json) for building the AMIs we use.
See the Flapjack docs on [package building](http://flapjack.io/docs/1.0/development/Package-Building/) and [getting going with boot2docker](http://flapjack.io/docs/1.0/development/Omnibus-In-Your-Docker/).

### AWS CLI Configuration

If you want the build rake task to publish to packages.flapjack.io then you'll need to have set up a valid configuration for aws cli. You can do this as follows:

```
./configure_awscli \
  --aws-access-key-id xxx \
  --aws-secret-access-key xxx \
  --default-region us-east-1
```

### Build

Run the `build` rake task. It drives `docker` and `omnibus` to build packages. You can also call the `build_and_publish` rake task (see below) if you want to also publish the package directly.

The following environment variables affect what `build` does:

- `BUILD_REF`                 - the branch, tag, or commit (on master) to build (Required). If a tag, it'll start with a v if it's a release tag, eg `v1.0.0rc5`
- `DISTRO`                    - only "ubuntu" is currently supported (Optional, Default: "ubuntu")
- `DISTRO_RELEASE`            - the release name, eg "precise" (Optional, Default: "trusy")
- `DRY_RUN`                   - if set, just shows what would be gone (Optional, Default: nil)
- `OFFICIAL_FLAPJACK_PACKAGE` - if true, signs built packages, assuming that the Flapjack Signing Key is on the system


Eg:

```
export BUILD_REF="1.1.0"
export DISTRO="ubuntu"
export DISTRO_RELEASE="precise"
export OFFICIAL_FLAPJACK_PACKAGE="true"

bundle exec rake build
```

### Publish

Run the `publish` rake task to publish a previously built package. The package is added to the *experimental* component of your apt package repo.

The following environment variable is required:

- `PACKAGE_FILE` - the filename of the package file you've just built and want to publish

Eg:

```bash
export PACKAGE_FILE=flapjack_1.1.0~+20141003112645-master-trusty-1_amd64.deb
bundle exec rake build
```

### Build and Publish

The rake task `build_and_publish` just calls the `build` and `publish` rake tasks sequentially. You don't need to set the `PACKAGE_FILE` environment variable however, as the package meta data is already determined.

The environment variables are as per the `build` rake task.

Eg:

```
export BUILD_REF="1.1.0"
export DISTRO="ubuntu"
export DISTRO_RELEASE="precise"
bundle exec rake build_and_publish
```


### Promote from Experimental to Main

When testing of the package candidiate is completed, use the `promote` script to repackage the deb for the **main** component in the case of debs, or copy the package to `flapjack` from `flapjack-experimental` in the case of rpms.

You'll need the name of the candidate package, which will be in the output of `build`, or look in S3 to find it. Eg:

```shell
$ ./promote candidate_flapjack_1.0.0~rc6~20140820210002-master-precise-1_amd64.deb
```

### Testing Packages

To test a specific package file, set `PACKAGE_FILE` the same as in the Publish section, above:
```bash
PACKAGE_FILE=flapjack_1.2.1-precise_amd64.deb bundle exec rake test
```

### Tests

Tests are fairly minimal right now, would you like to expand them? Check out the spec directory! Run with:

```
bundle install
bundle exec rspec
```

