###############################################################################
# PROJECT NAME CONFIGURATION
###############################################################################
# Name: coretaceous
#
# IMPORTANT: Change "coretaceous" above to your desired project name.
# This name should be used consistently throughout the repository in:
#   - Justfile: export image_name := env("IMAGE_NAME", "your-name-here")
#   - README.md: # your-name-here (title)
#   - artifacthub-repo.yml: repositoryID: your-name-here
#   - custom/ujust/README.md: localhost/your-name-here:stable (in bootc switch example)
#
# The project name defined here is the single source of truth for your
# custom image's identity. When changing it, update all references above
# to maintain consistency.
###############################################################################

###############################################################################
# MULTI-STAGE BUILD ARCHITECTURE
###############################################################################
# This Containerfile follows the Bluefin architecture pattern as implemented in
# @projectbluefin/distroless. The architecture layers OCI containers together:
#
# 1. Context Stage (ctx) - Combines resources from:
#    - Local build scripts and custom files
#    - @projectbluefin/common - Desktop configuration shared with Aurora 
#    - @ublue-os/brew - Homebrew integration
#
# 2. Base Image Options:
#    - `ghcr.io/ublue-os/silverblue-main:latest` (Fedora and GNOME)
#    - `ghcr.io/ublue-os/base-main:latest` (Fedora and no desktop 
#    - `quay.io/centos-bootc/centos-bootc:stream10 (CentOS-based)` 
#
# See: https://docs.projectbluefin.io/contributing/ for architecture diagram
###############################################################################

# Context stage - combine local and imported OCI container resources
FROM scratch AS ctx

COPY build /build
COPY custom /custom
# Copy from OCI containers to distinct subdirectories to avoid conflicts
# Note: Renovate can automatically update these :latest tags to SHA-256 digests for reproducibility
COPY --from=ghcr.io/projectbluefin/common:latest@sha256:340a50261c40705c43812cddcd28e698e3ee1a6832fa95484fb039e0a93fd482 /system_files/shared /oci/common/shared
COPY --from=ghcr.io/projectbluefin/common:latest@sha256:340a50261c40705c43812cddcd28e698e3ee1a6832fa95484fb039e0a93fd482 /system_files/bluefin/usr/share/ublue-os/just /oci/common/bluefin/usr/share/ublue-os/just
COPY --from=ghcr.io/ublue-os/brew:latest@sha256:837fd51428e23fbe68b9d35651b0b4158b18c68045f54f00d2410b5c8ad4d363 /system_files /oci/brew

COPY --from=ghcr.io/rpassmore/linux-dynamic-wallpapers:latest@sha256:f368b1b3c7ffa3303719b13cf2442527f7219591de3add0ba3e901d6b0bbf3a1 /system_files /oci/wallpapers

# Base Image - GNOME included
FROM ghcr.io/ublue-os/silverblue-nvidia:43@sha256:a916af26ba9a37cb5fb3a0d0d45b767a0b2392c9bc1d0ec2a3137dbed8cf4b8c

### /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

### MODIFICATIONS
## Make modifications desired in your image and install packages by modifying the build scripts.
## The following RUN directive mounts the ctx stage which includes:
##   - Local build scripts from /build
##   - Local custom files from /custom
##   - Files from @projectbluefin/common at /oci/common
##   - Files from @projectbluefin/branding at /oci/branding
##   - Files from @ublue-os/artwork at /oci/artwork
##   - Files from @ublue-os/brew at /oci/brew
## Scripts are run in numerical order (10-build.sh, 20-example.sh, etc.)

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/run-scripts.sh

# Register systemd tmpfiles initialization directive for macadam and libvirt
RUN echo "d /var/usr/local/bin 0755 root root -" > /usr/lib/tmpfiles.d/macadam-dirs.conf
RUN echo "d /var/lib/libvirt 0755 root root -" > /usr/lib/tmpfiles.d/libvirt-dirs.conf \
 && echo "d /var/lib/swtpm-localca 0750 root root -" >> /usr/lib/tmpfiles.d/libvirt-dirs.conf

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
